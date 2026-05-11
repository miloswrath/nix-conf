{
  lib,
  pkgs,
  inputs,
  videoDriver,
  hostname,
  browser,
  editor,
  terminal,
  terminalFileManager,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/hardware/video/${videoDriver}.nix # Enable gpu drivers defined in flake.nix
    ../../modules/hardware/drives

    ../common.nix
    ../../modules/scripts

    ../../modules/desktop/hyprland # Enable hyprland window manager
    # ../../modules/desktop/i3-gaps # Enable i3 window manager

    ../../modules/programs/games
    #../../modules/programs/browser/${browser} # Set browser defined in flake.nix
    ../../modules/programs/terminal/${terminal} # Set terminal defined in flake.nix
    ../../modules/programs/editor/${editor} # Set editor defined in flake.nix
    ../../modules/programs/editor/vscode
    ../../modules/programs/cli/${terminalFileManager} # Set file-manager defined in flake.nix
    ../../modules/programs/cli/starship
    ../../modules/programs/cli/tmux
    ../../modules/programs/cli/direnv
    ../../modules/programs/cli/lazygit
    ../../modules/programs/cli/cava
    ../../modules/programs/cli/btop
    #../../modules/programs/cli/molt
    ../../modules/programs/cli/opencode
    ../../modules/programs/cli/lmstudio
    #../../modules/programs/cli/codex
    ../../modules/programs/shell/bash
    ../../modules/programs/shell/zsh
    ../../modules/programs/media/discord
    ../../modules/programs/media/spicetify
    # ../../modules/programs/media/youtube-music
    # ../../modules/programs/media/thunderbird
     ../../modules/programs/media/obs-studio
    ../../modules/programs/media/mpv
    ../../modules/programs/misc/tlp
    ../../modules/programs/misc/thunar
    ../../modules/programs/misc/lact # GPU fan, clock and power configuration
    ../../modules/programs/misc/nix-ld
    # ../../modules/programs/misc/virt-manager
    ../../modules/programs/misc/calcurse
    #../../modules/programs/misc/openconnect-sso
  ];

  # Home-manager config
  home-manager.sharedModules = [
    inputs.caelestia-shell.homeManagerModules.default
    (_: {
      home.packages = with pkgs; [
        # pokego # Overlayed
        # krita
        #github-desktop
        # gimp
        codex
        claude-code
        obsidian
        zotero
        brave
        #monero-gui
        proton-vpn
        libreoffice-qt-fresh
        zoom-us
        devenv
        pi-coding-agent
        ani-cli
      ];
      programs.caelestia = {
        enable = true;
        systemd = {
          enable = true; # start from compositor manually
          target = "graphical-session.target";
          environment = [];
        };
        settings = {
          bar.status = {
            showBattery = false;
          };
          paths.wallpaperDir = "~/NixOS/modules/themes/wallpapers-ca";
        };
        extraConfig = builtins.toJSON {
          general = {
            apps = {
              terminal = [ "kitty" ];
              explorer = [ "thunar" ];
              playback = [ "mpv" ];
            };
          };
          appearance = {
            rounding.scale = 0.85;
          };
          background = {
            desktopClock = {
              enable = true;
              position = "bottom-right";
              scale = 1.0;
            };
          };
          bar = {
            clock.showIcon = true;
            status = {
              showAudio = true;
              showMicrophone = true;
            };
            tray.compact = true;
          };
          services = {
            useFahrenheit = false;
            useTwelveHourClock = false;
          };
          launcher = {
            vimKeybinds = true;
          };
          utilities = {
            toasts = {
              nowPlaying.enable = true;
            };
          };
        };        
        cli = {
          enable = true; # Also add caelestia-cli to path
          settings = {
            theme.enableGtk = false;
          };
        };
      };
    })
  ];
  # Define system packages here
  environment.systemPackages = with pkgs; [
    wl-gammarelay-rs
    krb5
    cifs-utils
    keyutils
    samba
    ffmpeg
    bubblewrap
    quickshell
  ];
  security.krb5 = {
    enable = true;
    settings = {
      libdefaults = {
        default_realm = "IOWA.UIOWA.EDU";
        dns_lookup_realm = true;
        dns_lookup_kdc = true;
        rdns = false;
        default_ccache_name = "KEYRING:persistent:%{uid}";
      };
      domain_realm = {
        ".uiowa.edu" = "IOWA.UIOWA.EDU";
        "uiowa.edu" = "IOWA.UIOWA.EDU";
      };
    };
  };
  system.activationScripts.symlink-requestkey = ''
    if [ ! -d /sbin ]; then
      mkdir /sbin
    fi
    ln -sfn /run/current-system/sw/bin/request-key /sbin/request-key
  '';
  # request-key expects a configuration file under /etc
  environment.etc."request-key.conf" = lib.mkForce {
    text = let
      upcall = "/run/wrappers/bin/cifs_upcall";
      keyctl = "${pkgs.keyutils}/bin/keyctl";
      dnsres = "${pkgs.keyutils}/sbin/key.dns_resolver";
    in ''
      #OP     TYPE          DESCRIPTION  CALLOUT_INFO  PROGRAM
      create  cifs.spnego   *            *             ${upcall} -t %k

      # correct handler for dns_resolver:
      create  dns_resolver  *            *             ${dnsres} %k

      # (rest of your defaults/debug handlers)
      create  user          debug:*      negate        ${keyctl} negate %k 30 %S
      create  user          debug:*      rejected      ${keyctl} reject %k 30 %c %S
      create  user          debug:*      expired       ${keyctl} reject %k 30 %c %S
      create  user          debug:*      revoked       ${keyctl} reject %k 30 %c %S
      create  user          debug:loop:* *             |${pkgs.coreutils}/bin/cat
      create  user          debug:*      *             ${pkgs.keyutils}/share/keyutils/request-key-debug.sh %k %d %c %S
      negate  *             *            *             ${keyctl} negate %k 30 %S
    '';
  };

  security.wrappers.cifs_upcall = {
    source = lib.getExe' pkgs.cifs-utils "cifs.upcall";
    owner = "root";
    group = "root";
    setuid = true;
  };

  networking = {
    hostName = hostname;

    firewall.allowedTCPPorts = [ 2049 ];  # NFS
    firewall.allowedUDPPorts = [ 2049 ];

    networkmanager.wifi.scanRandMacAddress = false;
  };
  services.samba = {
    enable = true;
    settings = {
      public = {
        path = "/srv/shared";
        browseable = true;
        "read only" = false;
        "guest ok" = true;
      };
    };
  };
  # Enable NFS server
  services.nfs.server.enable = true;

  # Export your desired directory
  services.nfs.server.exports = ''
    /srv/shared 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
  '';
  # Stream my media to my devices via the network
  services.minidlna = {
    enable = true;
    openFirewall = true;
    settings = {
      friendly_name = "NixOS-DLNA";
      media_dir = [
        # A = Audio, P = Pictures, V, = Videos, PV = Pictures and Videos.
        # "A,/mnt/work/Pimsleur/Russian"
        "/mnt/work/Pimsleur"
        "/mnt/work/Media/Films"
        "/mnt/work/Media/Series"
        "/mnt/work/Media/Videos"
        "/mnt/work/Media/Music"
      ];
      inotify = "yes";
      log_level = "error";
    };
  };
  virtualisation.docker = {
    enable = true;
  };
  users.users.zak.extraGroups = [ "docker" ];
  users.users.minidlna = {
    extraGroups = ["users"]; # so minidlna can access the files.
  };
}
