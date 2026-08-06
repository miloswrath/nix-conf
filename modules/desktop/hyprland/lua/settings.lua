-- Environment Variables
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("NIXOS_OZONE_WL", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("EGL_PLATFORM", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE", "1")
hl.env("NIXPKGS_ALLOW_UNFREE", "1")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("WLR_DRM_NO_ATOMIC", "0")

-- Startup (variables.lua globals: wl_paste, batterynotify)
hl.on("hyprland.start", function()
	-- Propagate the full Hyprland environment to systemd/dbus-launched apps.
	hl.exec_cmd("systemctl --user import-environment")
	hl.exec_cmd("hash dbus-update-activation-environment 2>/dev/null && dbus-update-activation-environment --systemd --all")
	hl.exec_cmd("systemctl --user start hyprland-session.target")
	hl.exec_cmd("nm-applet --indicator")
	hl.exec_cmd("wl-clipboard-history -t")
	hl.exec_cmd(wl_paste .. " --type text --watch cliphist store")
	hl.exec_cmd(wl_paste .. " --type image --watch cliphist store")
	hl.exec_cmd("rm '$XDG_CACHE_HOME/cliphist/db'")
	hl.exec_cmd(batterynotify)
	hl.exec_cmd("polkit-agent-helper-1")
	hl.exec_cmd("pamixer --set-volume 50")
end)

hl.config({
	input = {
		kb_variant  = kbdVariant .. ",",
		repeat_delay = 300,
		repeat_rate  = 30,
		follow_mouse = 1,
		sensitivity  = -0.4,
		touchpad = { natural_scroll = false },
		tablet   = { output = "current" },
	},
	general = {
		gaps_in     = 4,
		gaps_out    = 9,
		border_size = 2,
		col = {
			active_border = {
				colors = { "rgba(ca9ee6ff)", "rgba(f2d5cfff)" },
				angle  = 45,
			},
			inactive_border = {
				colors = { "rgba(b4befecc)", "rgba(6c7086cc)" },
				angle  = 45,
			},
		},
		resize_on_border = true,
		layout = "dwindle",
	},
	decoration = {
		rounding    = 10,
		dim_special = 0.3,
		shadow = { enabled = false },
		blur = {
			enabled           = true,
			special           = true,
			size              = 6,
			passes            = 2,
			new_optimizations = true,
			ignore_opacity    = true,
			xray              = false,
		},
	},
	group = {
		col = {
			border_active = {
				colors = { "rgba(ca9ee6ff)", "rgba(f2d5cfff)" },
				angle  = 45,
			},
			border_inactive = {
				colors = { "rgba(b4befecc)", "rgba(6c7086cc)" },
				angle  = 45,
			},
			border_locked_active = {
				colors = { "rgba(ca9ee6ff)", "rgba(f2d5cfff)" },
				angle  = 45,
			},
			border_locked_inactive = {
				colors = { "rgba(b4befecc)", "rgba(6c7086cc)" },
				angle  = 45,
			},
		},
	},
	render = {
		-- Disabled: direct scanout bypasses the compositor, breaking PipeWire screen capture.
		-- Re-enable with `hyprctl keyword render:direct_scanout 2` when not streaming.
		direct_scanout = 0,
	},
	ecosystem = {
		no_update_news  = true,
		no_donation_nag = true,
	},
	misc = {
		disable_hyprland_logo      = true,
		mouse_move_focuses_monitor = true,
		swallow_regex              = "^(Alacritty|kitty)$",
		enable_swallow             = true,
		vrr = 0,
	},
	debug = {
		vfr = false,
	},
	xwayland = {
		force_zero_scaling = false,
	},
	dwindle = {
		preserve_split = true,
	},
	master = {
		new_status = "master",
		new_on_top = true,
		mfact      = 0.5,
	},
	binds = {
		workspace_back_and_forth = true,
	},
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
