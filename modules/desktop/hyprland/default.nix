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
    inherit (lib) concatStringsSep getExe getExe';

    mkRuleBlock = type: {name, match, rules}: let
      formattedRules = concatStringsSep "\n" (map (line: "  " + line) rules);
    in ''${type} {
  name = ${name}
  match:${match}
${formattedRules}
}
'';

    layerRuleBlocks =
      let
        layerRuleData = [
          {
            name = "rofi-blur";
            match = "namespace = rofi";
            rules = ["blur = yes"];
          }
          {
            name = "swaync-control-center";
            match = "namespace = swaync-control-center";
            rules = ["blur = yes"];
          }
          {
            name = "swaync-notifications";
            match = "namespace = swaync-notification-window";
            rules = ["blur = yes"];
          }
        ];
      in
        concatStringsSep "\n\n" (map (rule: mkRuleBlock "layerrule" rule) layerRuleData);

    windowRuleBlocks =
      let
        opacityRuleData = [
          {
            name = "opacity-terminals";
            match = "class = ^(kitty|alacritty|Alacritty|org.wezfurlong.wezterm)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-gcr-prompter";
            match = "class = ^(gcr-prompter)$";
            values = "0.90 0.90";
          }
          {
            name = "opacity-hyprpolkit-title";
            match = "title = ^(Hyprland Polkit Agent)$";
            values = "0.90 0.90";
          }
          {
            name = "opacity-firefox";
            match = "class = ^(firefox)$";
            values = "1.00 1.00";
          }
          {
            name = "opacity-brave";
            match = "class = ^(Brave-browser)$";
            values = "0.90 0.90";
          }
          {
            name = "opacity-thunar";
            match = "class = ^(thunar)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-steam";
            match = "class = ^(Steam|steam|steamwebhelper)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-spotify-class";
            match = "class = ^(Spotify)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-spotify-title";
            match = "title = (.*)(Spotify)(.*)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-vscodium";
            match = "class = ^(VSCodium)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-codium-url-handler";
            match = "class = ^(codium-url-handler)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-code";
            match = "class = ^(code)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-code-url-handler";
            match = "class = ^(code-url-handler)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-terminal-file-manager";
            match = "class = ^(terminalFileManager)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-dolphin";
            match = "class = ^(org.kde.dolphin)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-ark";
            match = "class = ^(org.kde.ark)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-nwg-look";
            match = "class = ^(nwg-look)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-qt5ct";
            match = "class = ^(qt5ct)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-qt6ct";
            match = "class = ^(qt6ct)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-yad";
            match = "class = ^(yad)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-clapper";
            match = "class = ^(com.github.rafostar.Clapper)$";
            values = "0.90 0.90";
          }
          {
            name = "opacity-flatseal";
            match = "class = ^(com.github.tchx84.Flatseal)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-cartridges";
            match = "class = ^(hu.kramo.Cartridges)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-obs";
            match = "class = ^(com.obsproject.Studio)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-gnome-boxes";
            match = "class = ^(gnome-boxes)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-discord";
            match = "class = ^(discord)$";
            values = "0.90 0.90";
          }
          {
            name = "opacity-webcord";
            match = "class = ^(WebCord)$";
            values = "0.90 0.90";
          }
          {
            name = "opacity-warp";
            match = "class = ^(app.drey.Warp)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-protonup";
            match = "class = ^(net.davidotek.pupgui2)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-signal";
            match = "class = ^(Signal)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-upscaler";
            match = "class = ^(io.gitlab.theevilskeleton.Upscaler)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-obsidian";
            match = "class = ^(obsidian)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-zotero";
            match = "class = ^(Zotero)$";
            values = "0.80 0.80";
          }
          {
            name = "opacity-pavucontrol";
            match = "class = ^(pavucontrol)$";
            values = "0.80 0.70";
          }
          {
            name = "opacity-pulseaudio";
            match = "class = ^(org.pulseaudio.pavucontrol)$";
            values = "0.80 0.70";
          }
          {
            name = "opacity-blueman";
            match = "class = ^(blueman-manager|.blueman-manager-wrapped)$";
            values = "0.80 0.70";
          }
          {
            name = "opacity-nm";
            match = "class = ^(nm-applet|nm-connection-editor)$";
            values = "0.80 0.70";
          }
          {
            name = "opacity-polkit-kde";
            match = "class = ^(org.kde.polkit-kde-authentication-agent-1)$";
            values = "0.80 0.70";
          }
        ];

        floatRuleData = [
          {name = "float-qt5ct"; match = "class = ^(qt5ct)$";}
          {name = "float-nwg-look"; match = "class = ^(nwg-look)$";}
          {name = "float-ark"; match = "class = ^(org.kde.ark)$";}
          {name = "float-signal"; match = "class = ^(Signal)$";}
          {name = "float-clapper"; match = "class = ^(com.github.rafostar.Clapper)$";}
          {name = "float-warp"; match = "class = ^(app.drey.Warp)$";}
          {name = "float-protonup"; match = "class = ^(net.davidotek.pupgui2)$";}
          {name = "float-eog"; match = "class = ^(eog)$";}
          {name = "float-upscaler"; match = "class = ^(io.gitlab.theevilskeleton.Upscaler)$";}
          {name = "float-yad"; match = "class = ^(yad)$";}
          {name = "float-pavucontrol"; match = "class = ^(pavucontrol)$";}
          {name = "float-blueman"; match = "class = ^(blueman-manager|.blueman-manager-wrapped)$";}
          {name = "float-nm"; match = "class = ^(nm-applet|nm-connection-editor)$";}
          {name = "float-polkit-kde"; match = "class = ^(org.kde.polkit-kde-authentication-agent-1)$";}
        ];

        baseRules = [
          {
            name = "tile-godot";
            match = "title = (.*)(Godot)(.*)$";
            rules = ["tile = yes"];
          }
          {
            name = "content-games";
            match = "tag = games";
            rules = ["content = game"];
          }
          {
            name = "tag-from-content";
            match = "content = game";
            rules = ["tag = +games"];
          }
          {
            name = "tag-steam-apps";
            match = "class = ^(steam_app.*|steam_app_\\d+)$";
            rules = ["tag = +games"];
          }
          {
            name = "tag-gamescope";
            match = "class = ^(gamescope)$";
            rules = ["tag = +games"];
          }
          {
            name = "tag-waydroid";
            match = "class = (Waydroid)";
            rules = ["tag = +games"];
          }
          {
            name = "tag-osu";
            match = "class = (osu!)";
            rules = ["tag = +games"];
          }
        ];

        mappedOpacities = map (rule: {
          name = rule.name;
          match = rule.match;
          rules = ["opacity = ${rule.values}"];
        }) opacityRuleData;

        mappedFloats = map (rule: {
          name = rule.name;
          match = rule.match;
          rules = ["float = yes"];
        }) floatRuleData;
      in
        concatStringsSep "\n\n"
        (map (rule: mkRuleBlock "windowrule" rule) (baseRules ++ mappedOpacities ++ mappedFloats));
  in [
    ({...}: {
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
        #waybar
        wtype
        wl-clipboard
        xdotool
        yad
        # socat # for and autowaybar.sh
        # jq # for and autowaybar.sh
      ];

      xdg.configFile."hypr/icons" = {
        source = ./icons;
        recursive = true;
      };

      #test later systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
      wayland.windowManager.hyprland = {
        enable = true;
        plugins = [
          # inputs.hyprland-plugins.packages.${pkgs.system}.hyprwinwrap
        ];
        systemd = {
          enable = true;
          variables = ["--all"];
        };
        settings = {
          "$mainMod" = "SUPER";
          "$term" = "${getExe pkgs.${terminal}}";
          "$editor" = "code --disable-gpu";
          "$fileManager" = "$term --class \"terminalFileManager\" -e ${terminalFileManager}";
          "$browser" = browser;

          env = [
            "XDG_CURRENT_DESKTOP,Hyprland"
            "XDG_SESSION_DESKTOP,Hyprland"
            "XDG_SESSION_TYPE,wayland"
            "GDK_BACKEND,wayland,x11,*"
            "NIXOS_OZONE_WL,1"
            "ELECTRON_OZONE_PLATFORM_HINT,auto"
            "MOZ_ENABLE_WAYLAND,1"
            "OZONE_PLATFORM,wayland"
            "EGL_PLATFORM,wayland"
            "CLUTTER_BACKEND,wayland"
            "SDL_VIDEODRIVER,wayland"
            "QT_QPA_PLATFORM,wayland;xcb"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "QT_QPA_PLATFORMTHEME,qt6ct"
            "QT_AUTO_SCREEN_SCALE_FACTOR,1"
            "WLR_RENDERER_ALLOW_SOFTWARE,1"
            "NIXPKGS_ALLOW_UNFREE,1"
            "AQ_DRM_DEVICES,/dev/dri/card1"
          ];
          exec-once = [
            #"[workspace 1 silent] ${terminal}"
            #"[workspace 5 silent] ${browser}"
            #"[workspace 6 silent] spotify"
            #"[workspace special silent] ${browser} --private-window"
            #"[workspace special silent] ${terminal}"

            #"waybar"
            #"swaync"
            "nm-applet --indicator"
            "wl-clipboard-history -t"
            "${getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch cliphist store" # clipboard store text data
            "${getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch cliphist store" # clipboard store image data
            "rm '$XDG_CACHE_HOME/cliphist/db'" # Clear clipboard
            "${./scripts/batterynotify.sh}" # battery notification
            # "${./scripts/autowaybar.sh}" # uncomment packages at the top
            "polkit-agent-helper-1"
            "pamixer --set-volume 50"
          ];
          input = {
            kb_layout = "${kbdLayout},ru";
            kb_variant = "${kbdVariant},";
            repeat_delay = 300; # or 212
            repeat_rate = 30;

            follow_mouse = 1;

            touchpad.natural_scroll = false;

            tablet.output = "current";

            sensitivity = 0.4; # -1.0 - 1.0, 0 means no modification.
          };
          general = {
            gaps_in = 4;
            gaps_out = 9;
            border_size = 2;
            "col.active_border" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
            "col.inactive_border" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
            resize_on_border = true;
            layout = "dwindle"; # dwindle or master
            # allow_tearing = true; # Allow tearing for games (use immediate window rules for specific games or all titles)
          };
          decoration = {
            shadow.enabled = false;
            rounding = 10;
            dim_special = 0.3;
            blur = {
              enabled = true;
              special = true;
              size = 6; # 6
              passes = 2; # 3
              new_optimizations = true;
              ignore_opacity = true;
              xray = false;
            };
          };
          group = {
            "col.border_active" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
            "col.border_inactive" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
            "col.border_locked_active" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
            "col.border_locked_inactive" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
          };
          animations = {
            enabled = true;
            bezier = [
              "linear, 0, 0, 1, 1"
              "md3_standard, 0.2, 0, 0, 1"
              "md3_decel, 0.05, 0.7, 0.1, 1"
              "md3_accel, 0.3, 0, 0.8, 0.15"
              "overshot, 0.05, 0.9, 0.1, 1.1"
              "crazyshot, 0.1, 1.5, 0.76, 0.92"
              "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
              "fluent_decel, 0.1, 1, 0, 1"
              "easeInOutCirc, 0.85, 0, 0.15, 1"
              "easeOutCirc, 0, 0.55, 0.45, 1"
              "easeOutExpo, 0.16, 1, 0.3, 1"
            ];
            animation = [
              "windows, 1, 3, md3_decel, popin 60%"
              "border, 1, 10, default"
              "fade, 1, 2.5, md3_decel"
              # "workspaces, 1, 3.5, md3_decel, slide"
              "workspaces, 1, 3.5, easeOutExpo, slide"
              # "workspaces, 1, 7, fluent_decel, slidefade 15%"
              # "specialWorkspace, 1, 3, md3_decel, slidefadevert 15%"
              "specialWorkspace, 1, 3, md3_decel, slidevert"
            ];
          };
          render = {
            direct_scanout = 2; # 0 = off, 1 = on, 2 = auto (on with content type ‘game’)
          };
          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };
          misc = {
            disable_hyprland_logo = true;
            mouse_move_focuses_monitor = true;
            swallow_regex = "^(Alacritty|kitty)$";
            enable_swallow = true;
            vfr = true; # always keep on
            vrr = 1; # enable variable refresh rate (0=off, 1=on, 2=fullscreen only)
          };
          xwayland.force_zero_scaling = false;
          gesture = "3, horizontal, workspace,";
          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };
          master = {
            new_status = "master";
            new_on_top = true;
            mfact = 0.5;
          };
          binde = [
            # caelestia
            # Resize windows
            "$mainMod SHIFT, right, resizeactive, 30 0"
            "$mainMod SHIFT, left, resizeactive, -30 0"
            "$mainMod SHIFT, up, resizeactive, 0 -30"
            "$mainMod SHIFT, down, resizeactive, 0 30"

            # Resize windows with hjkl keys
            "$mainMod SHIFT, l, resizeactive, 30 0"
            "$mainMod SHIFT, h, resizeactive, -30 0"
            "$mainMod SHIFT, k, resizeactive, 0 -30"
            "$mainMod SHIFT, j, resizeactive, 0 30"

            # Functional keybinds
            ",XF86MonBrightnessDown,exec,brightnessctl set 2%-"
            ",XF86MonBrightnessUp,exec,brightnessctl set +2%"
            ",XF86AudioLowerVolume,exec,pamixer -d 2"
            ",XF86AudioRaiseVolume,exec,pamixer -i 2"
          ];
          bind = let
            autoclicker = pkgs.callPackage ./scripts/autoclicker.nix {};
          in
            [
              # Keybinds help menu
              "$mainMod, question, exec, ${./scripts/keybinds.sh}"
              "$mainMod, slash, exec, ${./scripts/keybinds.sh}"
              "$mainMod CTRL, K, exec, ${./scripts/keybinds.sh}"

              "$mainMod, F8, exec, kill $(cat /tmp/auto-clicker.pid) 2>/dev/null || ${lib.getExe autoclicker} --cps 40"
              # "$mainMod ALT, mouse:276, exec, kill $(cat /tmp/auto-clicker.pid) 2>/dev/null || ${lib.getExe autoclicker} --cps 60"

              # Night Mode (lower value means warmer temp)
              "$mainMod, F9, exec, ${getExe pkgs.hyprsunset} --temperature 3500" # good values: 3500, 3000, 2500
              "$mainMod, F10, exec, pkill hyprsunset"

              # Window/Session actions
              "$mainMod, Q, exec, ${./scripts/dontkillsteam.sh}" # killactive, kill the window on focus
              "ALT, F4, exec, ${./scripts/dontkillsteam.sh}" # killactive, kill the window on focus
              "$mainMod, delete, exit" # kill hyperland session
              "$mainMod, W, togglefloating" # toggle the window on focus to float
              "$mainMod SHIFT, G, togglegroup" # toggle the window on focus to float
              "ALT, return, fullscreen" # toggle the window on focus to fullscreen
              "$mainMod ALT, L, global, caelestia:lock" # lock screen
              "$mainMod, backspace, exec, pkill -x wlogout || wlogout -b 4" # logout menu
              "$CONTROL, ESCAPE, exec, pkill waybar || waybar" # toggle waybar

              # Applications/Programs
              "$mainMod, Return, exec, $term"
              "$mainMod, T, exec, $term"
              "$mainMod, E, exec, $fileManager"
              "$mainMod, C, exec, $editor"
              "$mainMod, F, exec, $browser"
              "$mainMod SHIFT, S, exec, spotify"
              "$mainMod SHIFT, Y, exec, youtube-music"
              "$CONTROL ALT, DELETE, exec, $term -e '${getExe pkgs.btop}'" # System Monitor
              "$mainMod CTRL, C, exec, hyprpicker --autocopy --format=hex" # Colour Picker

              "$mainMod, A, global, caelestia:launcher" 
              #"$mainMod, A, exec, pkill -x rofi || ${./scripts/rofi.sh} drun" # launch desktop applications
              "$mainMod, SPACE, exec, pkill -x rofi || ${./scripts/rofi.sh} drun" # launch desktop applications
              "$mainMod, Z, exec, pkill -x rofi || ${./scripts/rofi.sh} emoji" # launch emoji picker
              # "$mainMod, tab, exec, pkill -x rofi || ${./scripts/rofi.sh} window" # switch between desktop applications
              # "$mainMod, R, exec, pkill -x rofi || ${./scripts/rofi.sh} file" # brrwse system files
              "$mainMod ALT, K, exec, ${./scripts/keyboardswitch.sh}" # change keyboard layout
              "$mainMod SHIFT, N, exec, swaync-client -t -sw" # swayNC panel
              "$mainMod SHIFT, Q, exec, swaync-client -t -sw" # swayNC panel
              "$mainMod, G, exec, ${./scripts/rofi.sh} games" # game launcher
              "$mainMod ALT, G, exec, ${./scripts/gamemode.sh}" # disable hypr effects for gamemode
              "$mainMod, V, exec, ${./scripts/ClipManager.sh}" # Clipboard Manager
              "$mainMod, M, exec, pkill -x rofi || ${./scripts/rofimusic.sh}" # online music

              # Screenshot/Screencapture
              "$mainMod, P, exec, ${./scripts/screenshot.sh} s" # drag to snip an area / click on a window to print it
              "$mainMod CTRL, P, exec, ${./scripts/screenshot.sh} sf" # frozen screen, drag to snip an area / click on a window to print it
              "$mainMod, print, exec, ${./scripts/screenshot.sh} m" # print focused monitor
              "$mainMod ALT, P, exec, ${./scripts/screenshot.sh} p" # print all monitor outputs

              # Functional keybinds
              ",xf86Sleep, exec, systemctl suspend" # Put computer into sleep mode
              ",XF86AudioMicMute,exec,pamixer --default-source -t" # mute mic
              ",XF86AudioMute,exec,pamixer -t" # mute audio
              ",XF86AudioPlay,exec,playerctl play-pause" # Play/Pause media
              ",XF86AudioPause,exec,playerctl play-pause" # Play/Pause media
              ",xf86AudioNext,exec,playerctl next" # go to next media
              ",xf86AudioPrev,exec,playerctl previous" # go to previous media

              # ",xf86AudioNext,exec,${./scripts/MediaCtrl.sh} next" # go to next media
              # ",xf86AudioPrev,exec,${./scripts/MediaCtrl.sh} previous" # go to previous media
              # ",XF86AudioPlay,exec,${./scripts/MediaCtrl.sh} play-pause" # go to next media
              # ",XF86AudioPause,exec,${./scripts/MediaCtrl.sh} play-pause" # go to next media

              # to switch between windows in a floating workspace
              "$mainMod, Tab, cyclenext"
              "$mainMod, Tab, bringactivetotop"

              # Switch workspaces relative to the active workspace with mainMod + CTRL + [←→]
              "$mainMod CTRL, right, workspace, r+1"
              "$mainMod CTRL, left, workspace, r-1"

              # move to the first empty workspace instantly with mainMod + CTRL + [↓]
              "$mainMod CTRL, down, workspace, empty"

              # Move focus with mainMod + arrow keys
              "$mainMod, left, movefocus, l"
              "$mainMod, right, movefocus, r"
              "$mainMod, up, movefocus, u"
              "$mainMod, down, movefocus, d"
              "ALT, Tab, movefocus, d"

              # Move focus with mainMod + HJKL keys
              "$mainMod, h, movefocus, l"
              "$mainMod, l, movefocus, r"
              "$mainMod, k, movefocus, u"
              "$mainMod, j, movefocus, d"

              # Go to workspace 6 and 7 with mouse side buttons
              "$mainMod, mouse:276, workspace, 5"
              "$mainMod, mouse:275, workspace, 6"
              "$mainMod SHIFT, mouse:276, movetoworkspace, 5"
              "$mainMod SHIFT, mouse:275, movetoworkspace, 6"
              "$mainMod CTRL, mouse:276, movetoworkspacesilent, 5"
              "$mainMod CTRL, mouse:275, movetoworkspacesilent, 6"

              # Rebuild NixOS with a KeyBind
              "$mainMod, U, exec, $term -e ${./scripts/rebuild.sh}"

              # Scroll through existing workspaces with mainMod + scroll
              "$mainMod, mouse_down, workspace, e+1"
              "$mainMod, mouse_up, workspace, e-1"

              # Move active window to a relative workspace with mainMod + CTRL + ALT + [←→]
              "$mainMod CTRL ALT, right, movetoworkspace, r+1"
              "$mainMod CTRL ALT, left, movetoworkspace, r-1"

              # Move active window around current workspace with mainMod + SHIFT + CTRL [←→↑↓]
              "$mainMod SHIFT $CONTROL, left, movewindow, l"
              "$mainMod SHIFT $CONTROL, right, movewindow, r"
              "$mainMod SHIFT $CONTROL, up, movewindow, u"
              "$mainMod SHIFT $CONTROL, down, movewindow, d"

              # Move active window around current workspace with mainMod + SHIFT + CTRL [HLJK]
              "$mainMod SHIFT $CONTROL, H, movewindow, l"
              "$mainMod SHIFT $CONTROL, L, movewindow, r"
              "$mainMod SHIFT $CONTROL, K, movewindow, u"
              "$mainMod SHIFT $CONTROL, J, movewindow, d"

              # Special workspaces (scratchpad)
              "$mainMod CTRL, S, movetoworkspacesilent, special"
              "$mainMod ALT, S, movetoworkspacesilent, special"
              "$mainMod, S, togglespecialworkspace,"
            ]
            ++ (builtins.concatLists (builtins.genList (x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mainMod, ${ws}, workspace, ${toString (x + 1)}"
                "$mainMod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                "$mainMod CTRL, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
              ])
              10));
          bindm = [
            # Move/Resize windows with mainMod + LMB/RMB and dragging
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];
        };
        extraConfig = ''
${layerRuleBlocks}

${windowRuleBlocks}

binds {
  workspace_back_and_forth = 1
}

# 0) Default monitor → leftmost, 1×
monitor=,preferred,auto,1

# 1) Internal laptop display (eDP-1) at 1.5×, auto-placed
monitor=desc:BOE NE135A1M-NY1,2880x1920@120,auto,1.25

# 2) External DP-4 (HP V27i G5, ID 2) → next slot, 1×
monitor=desc:DP-6,1920x1080@75,auto,1

# 3) External DP-8 (Dell P2419HC, ID 1) → rightmost, 1×
monitor=desc:DP-4,1920x1080@75,auto,1

# —————————————————————————————————————————————
# Workspace → monitor bindings
workspace=1,monitor:desc:BOE NE135A1M-NY1,default:true
workspace=2,monitor:desc:BOE NE135A1M-NY1
workspace=3,monitor:desc:BOE NE135A1M-NY1
workspace=4,monitor:desc:BOE NE135A1M-NY1

workspace=5,monitor:desc:DP-6
workspace=6,monitor:desc:DP-6
workspace=7,monitor:desc:DP-6

workspace=8,monitor:desc:DP-4
workspace=9,monitor:desc:DP-4
workspace=10,monitor:desc:DP-4
'';
      };
    })
  ];
}
