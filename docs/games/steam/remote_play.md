# Steam Remote Play — Native Desktop Streaming on Hyprland

## Overview

Steam Remote Play lets you stream your desktop or games to another device (Steam Deck, phone, another PC via Steam Link). Streaming a **game** is straightforward and works out of the box. Streaming the **native desktop** on Wayland is more complex because Steam needs a way to capture the compositor's output.

Your setup uses **Hyprland** (Wayland) with an **NVIDIA** GPU, which is one of the harder combinations due to Wayland's security model and NVIDIA's historically fragmented Wayland support. This doc covers both working approaches.

---

## How Desktop Streaming Works on Wayland

On X11, Steam captures the display directly via the X server. On Wayland, the compositor controls all buffer access, so Steam must go through one of:

- **PipeWire screen capture** via `xdg-desktop-portal` (preferred, privacy-aware)
- **Gamescope session** — gamescope acts as a nested compositor that Steam owns entirely, avoiding the portal layer

---

## Current Config Snapshot

| Component | Status |
|---|---|
| `remotePlay.openFirewall` | ✅ enabled |
| `gamescopeSession.enable` | ✅ enabled |
| `xdg-desktop-portal-hyprland` | ✅ installed |
| `xdg-desktop-portal-gtk` | ✅ installed |
| PipeWire + WirePlumber | ✅ enabled |
| `nvidia-vaapi-driver` | ✅ installed |
| `egl-wayland` | ✅ installed |
| `NVD_BACKEND=direct` | ✅ set |
| `xdg.portal.config` (explicit routing) | ⚠️ not set |

---

## Method 1: Hyprland Session + PipeWire (in-session streaming)

This runs Steam inside your normal Hyprland desktop and streams via PipeWire screen capture. It works but has known NVIDIA caveats.

### Step 1: Launch Steam with PipeWire flags

Steam must be started with the `-pipewire` flag to activate PipeWire-based screen capture. Without it, desktop streaming either falls back to X11 capture (XWayland only, misses Wayland windows) or shows a black screen.

Create a wrapper in your games module or launch Steam from terminal:

```bash
steam -pipewire -pipewire-dmabuf
```

To make this permanent, add a desktop entry override or set it as the Steam launch command. In NixOS you can patch the desktop entry or use a shell alias. The cleanest NixOS approach is a wrapper script:

```nix
# In modules/programs/games/default.nix
environment.systemPackages = with pkgs; [
  (pkgs.writeShellScriptBin "steam-pw" ''
    exec ${pkgs.steam}/bin/steam -pipewire -pipewire-dmabuf "$@"
  '')
];
```

### Step 2: Fix xdg-portal routing

Your current portal config installs both `xdg-desktop-portal-hyprland` and `xdg-desktop-portal-gtk` but doesn't explicitly tell xdg-desktop-portal which backend handles `ScreenCast`. This can cause ambiguity or fallback to the wrong portal. Add explicit routing in `common.nix`:

```nix
# In home-manager.users.${username}
xdg.portal = {
  enable = true;
  extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];
  xdgOpenUsePortal = true;
  config = {
    common = {
      default = [ "hyprland" "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
    };
  };
};
```

### Step 3: Ensure portal variables propagate

Hyprland's systemd integration (already enabled via `systemd.enable = true; variables = ["--all"];`) should propagate `WAYLAND_DISPLAY` and `XDG_CURRENT_DESKTOP` automatically. If screen capture fails, verify the portal is receiving them:

```bash
systemctl --user status xdg-desktop-portal-hyprland
systemctl --user status xdg-desktop-portal
```

If either shows missing variables, add to Hyprland `exec-once`:

```
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
```

### Step 4: Streaming the desktop

1. Open Steam on both the host and the remote device
2. On the remote device (Steam Deck, Steam Link app, etc.), browse to this machine under **Remote Play**
3. On the host machine you'll see a **"Stream Desktop"** button — click it to begin streaming your Hyprland session
4. A portal permission prompt will appear asking which screen/output to share — select your monitor

### Fullscreen game flickering during stream

When switching to a fullscreen game (e.g. Minecraft via XWayland), Hyprland's **direct scanout** can engage — this presents the game's framebuffer directly to the display hardware, bypassing the compositor. PipeWire captures through the compositor, so it loses frames and the stream flickers.

Root cause confirmed: Minecraft runs via XWayland (`xwayland: 1`) and requests fullscreen (`fullscreen: 2`), which triggers direct scanout.

**Fix** — disable direct scanout in `modules/desktop/hyprland/default.nix`:

```nix
render = {
  direct_scanout = 0;
};
```

Hyprland has no per-window rule for this, so it must be set globally. To temporarily re-enable it (when not streaming) without rebuilding:

```bash
hyprctl keyword render:direct_scanout 2
```

And to re-disable before a streaming session:

```bash
hyprctl keyword render:direct_scanout 0
```

### NVIDIA Caveats (Method 1)

NVIDIA's Wayland dmabuf path has historically caused black screens in screen capture. If `-pipewire-dmabuf` causes a black stream, try without it:

```bash
steam -pipewire
```

If you still get a black screen, NVIDIA NVFBC (NVidia Frame Buffer Capture) may be interfering. Disable hardware encoding on the streaming client side (Steam Settings > Remote Play > Advanced > uncheck "Enable hardware encoding on client") and test.

Additionally, `NVD_BACKEND=direct` (already set in your nvidia.nix) is required for `nvidia-vaapi-driver` to function correctly, which is used for hardware-accelerated video encode/decode in streaming.

### Known Limitation: Session Lock

When the host screen locks, xdg-desktop-portal revokes the screen-sharing permission. Video will freeze or go garbled after locking even if you unlock. The only current fix is to fully restart Steam on the host. Avoid locking the screen during active Remote Play sessions.

---

## Method 2: Gamescope Session (most reliable)

`gamescopeSession.enable = true` (already configured) adds a dedicated **"Steam"** session entry to SDDM. In this mode, gamescope is the compositor — Steam owns it entirely, no portal or XWayland capture needed. Desktop streaming works reliably here.

### How to use it

1. Log out of your Hyprland session
2. At the SDDM login screen, change the session from **"hyprland"** to **"Steam"** (bottom-left dropdown)
3. Log in — you'll boot directly into Steam Big Picture / gamescope
4. Remote Play desktop streaming works from here without any flags or portal config

### Customizing the gamescope session

The NixOS option accepts args for the gamescope compositor:

```nix
programs.steam.gamescopeSession = {
  enable = true;
  args = [
    "--adaptive-sync"    # VRR/G-Sync
    "--hdr-enabled"      # HDR if supported
  ];
  env = {
    MANGOHUD = "1";
  };
};
```

### NVIDIA + gamescope

With NVIDIA open kernel modules and `nvidia-drm.modeset=1` (already set), gamescope should work. If it fails to start, check:

```bash
journalctl --user -u gamescope-session
```

The env vars `GBM_BACKEND=nvidia-drm` and `__GLX_VENDOR_LIBRARY_NAME=nvidia` (set in your Hyprland env) carry into the gamescope session when launched from SDDM.

---

## Which Method to Use

| Scenario | Recommended method |
|---|---|
| Daily driver is Hyprland, occasional remote play | Method 1 with `-pipewire` |
| Dedicated streaming box / couch gaming rig | Method 2 (gamescope session) |
| Black screen issues on NVIDIA | Method 2 |
| Session lock is a concern | Method 2 |

---

## Firewall Ports

`remotePlay.openFirewall = true` already handles this, but for reference:

| Port | Protocol | Purpose |
|---|---|---|
| 27036 | TCP/UDP | Steam Remote Play |
| 27031–27036 | UDP | In-home streaming |

---

## Troubleshooting

**Black screen on the remote client**
- Confirm Steam is running with `-pipewire` flag
- Check portal is routing ScreenCast to hyprland: `systemctl --user status xdg-desktop-portal-hyprland`
- Try without `-pipewire-dmabuf` if using NVIDIA
- Fall back to gamescope session (Method 2)

**"Allow Remote Interaction" prompt every session**
- This is a known Wayland security model behavior — the portal permission is not persisted across sessions by default
- No permanent fix yet upstream; the prompt must be accepted each time Steam starts

**Video freezes after host screen locks**
- Known xdg-portal limitation: permission revoked on lock
- Restart Steam on host to restore streaming
- Avoid screen lock during active sessions

**No "Stream Desktop" button visible**
- Ensure the remote client is connected to the same Steam account
- Verify `remotePlay.openFirewall = true` is set and system was rebuilt
- Check both devices are on the same LAN (or Remote Play Anywhere is enabled in Steam settings)

**Audio drops or desync**
- Already using PipeWire with low-latency config (quantum 256/128) — this is good
- If audio issues persist with `-pipewire-dmabuf`, try `-pipewire` alone

---

## Sources

- [Steam Remote Play for Linux on Wayland — SteamClientBeta](https://steamcommunity.com/groups/SteamClientBeta/discussions/0/4336483289191762926/)
- [Add Wayland support for Steam Link — ValveSoftware/steam-for-linux#10220](https://github.com/ValveSoftware/steam-for-linux/issues/10220)
- [Remote Play with pipewire broken after session lock — ValveSoftware/steam-for-linux#9579](https://github.com/ValveSoftware/steam-for-linux/issues/9579)
- [Screen sharing — Hyprland Wiki](https://wiki.hypr.land/Useful-Utilities/Screen-Sharing/)
- [xdg-desktop-portal-hyprland — Hyprland Wiki](https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/)
- [Steam — NixOS Wiki](https://wiki.nixos.org/wiki/Steam)
- [Screen sharing on Hyprland — Bruno Ancona Sala gist](https://gist.github.com/brunoanc/2dea6ddf6974ba4e5d26c3139ffb7580)
- [Valve fixes up Steam Remote Play — GamingOnLinux](https://www.gamingonlinux.com/2024/03/valve-fixes-up-steam-remote-play-again/)
