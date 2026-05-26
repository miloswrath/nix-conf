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
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };

      home.packages = with pkgs; [
        hyprpaper
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
      ];

      xdg.configFile = {
        # Static Lua modules
        "hypr/hyprland.lua".source  = ./lua/hyprland.lua;
        "hypr/settings.lua".source  = ./lua/settings.lua;
        "hypr/animations.lua".source = ./lua/animations.lua;
        "hypr/monitors.lua".source  = ./lua/monitors.lua;
        "hypr/rules.lua".source     = ./lua/rules.lua;
        "hypr/binds.lua".source     = ./lua/binds.lua;

        "hypr/icons" = {
          source = ./icons;
          recursive = true;
        };

        # Generated: Nix-computed paths as flat Lua globals
        "hypr/variables.lua".text = ''
          -- Modifier
          mainMod = "SUPER"

          -- Applications
          term        = "${getExe pkgs.${terminal}}"
          editor      = "code --disable-gpu"
          browser     = "${browser}"
          fileManager = "${getExe pkgs.${terminal}} --class \"terminalFileManager\" -e ${terminalFileManager}"

          -- Keyboard layout (used by settings.lua)
          kbdLayout   = "${kbdLayout}"
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
      };
    })
  ];
}
