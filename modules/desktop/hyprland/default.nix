{
  lib,
  pkgs,
  browser,
  terminal,
  terminalFileManager,
  kbdLayout,
  kbdVariant,
  ...
}: {
  imports = [
    ../../themes/Catppuccin # Catppuccin GTK and QT themes
    ./programs/waybar
    ./programs/wlogout
    ./programs/rofi
    ./programs/hypridle
    ./programs/piper
    #./programs/hyprlock
    #./programs/swaync
    # ./programs/dunst
  ];

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  systemd.user.services.hyprpolkitagent = {
    description = "Hyprpolkitagent - Polkit authentication agent";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
  services.displayManager.defaultSession = "hyprland";

  programs.hyprland = {
    enable = true;
    # withUWSM = true;
  };

  home-manager.sharedModules = let
    inherit (lib) getExe getExe';
    autoclicker = pkgs.callPackage ./scripts/autoclicker.nix {};
  in [
    ({...}: {
      # Replicates home-manager's Hyprland systemd integration:
      # hyprland-session.target BindsTo graphical-session.target so that
      # starting it activates graphical-session.target (which has RefuseManualStart=yes).
      systemd.user.targets.hyprland-session = {
        Unit = {
          Description = "Hyprland compositor session";
          BindsTo = ["graphical-session.target"];
          Wants = ["graphical-session-pre.target"];
          After = ["graphical-session-pre.target"];
        };
      };

      home.packages = with pkgs; [
        hyprpaper
        mpvpaper
        hyprpicker
        cliphist
        grimblast
        swappy
        libnotify
        brightnessctl
        networkmanagerapplet
        pamixer
        pavucontrol
        playerctl
        wtype
        wl-clipboard
        xdotool
        yad
        wayland-utils
        wlroots
        wayland-protocols
        wl-gammactl
      ];

      xdg.configFile = {
        "hypr/icons" = {
          source = ./icons;
          recursive = true;
        };
      };

      wayland.windowManager.hyprland = {
        enable = true;
        configType = "lua";
        plugins = [
          # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprwinwrap
        ];

        # Numeric prefixes force load order (home-manager requires files
        # alphabetically): variables must load before settings/binds, which
        # reference its globals (mainMod, term, kbdVariant, script paths, ...).
        extraLuaFiles = {
          # Generated: Nix-computed store paths as flat Lua globals
          "00-variables" = ''
            -- Modifier
            mainMod = "SUPER"

            -- Applications
            term        = "${getExe pkgs.${terminal}}"
            editor      = "code --disable-gpu"
            browser     = "${browser}"
            fileManager = "${getExe pkgs.${terminal}} --class \"terminalFileManager\" -e ${terminalFileManager}"

            -- Keyboard layout (used by settings.lua)
            kbdVariant  = "${kbdVariant}"

            -- Binaries
            hyprsunset  = "${getExe pkgs.hyprsunset}"
            autoclicker = "${getExe autoclicker}"
            wl_paste    = "${getExe' pkgs.wl-clipboard "wl-paste"}"

            -- Scripts
            keybinds       = "${./scripts/keybinds.sh}"
            dontkillsteam  = "${./scripts/dontkillsteam.sh}"
            screenshot     = "${./scripts/screenshot.sh}"
            rebuild        = "${./scripts/rebuild.sh}"
            rofi_script    = "${./scripts/rofi.sh}"
            rofimusic      = "${./scripts/rofimusic.sh}"
            clipmanager    = "${./scripts/ClipManager.sh}"
            gamemode       = "${./scripts/gamemode.sh}"
            keyboardswitch = "${./scripts/keyboardswitch.sh}"
            batterynotify  = "${./scripts/batterynotify.sh}"
          '';

          "10-settings"   = ./lua/settings.lua;
          "20-animations" = ./lua/animations.lua;
          "30-monitors"   = ./lua/monitors.lua;
          "40-rules"      = ./lua/rules.lua;
          "50-binds"      = ./lua/binds.lua;
        };
      };
    })
  ];
}
