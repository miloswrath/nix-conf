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
    ../../modules/programs/editor/libre
    ../../modules/programs/cli/${terminalFileManager} # Set file-manager defined in flake.nix
    ../../modules/programs/cli/starship
    ../../modules/programs/cli/tmux
    ../../modules/programs/cli/direnv
    ../../modules/programs/cli/lazygit
    ../../modules/programs/cli/cava
    ../../modules/programs/cli/btop
    ../../modules/programs/cli/codex
    ../../modules/programs/shell/bash
    ../../modules/programs/shell/zsh
    ../../modules/programs/media/discord
    ../../modules/programs/media/spicetify
    #../../modules/programs/media/stremio
    # ../../modules/programs/media/youtube-music
    # ../../modules/programs/media/thunderbird
    # ../../modules/programs/media/obs-studio
    ../../modules/programs/media/mpv
    #../../modules/programs/misc/tlp
    ../../modules/programs/misc/thunar
    #../../modules/programs/misc/lact # GPU fan, clock and power configuration
    ../../modules/programs/misc/nix-ld
    ../../modules/programs/misc/virt-manager
    ../../modules/programs/misc/calcurse
    #../../modules/programs/misc/rstudio
    ../../modules/programs/misc/openconnect-sso
    ../../modules/programs/misc/tds
    ../../modules/programs/misc/glance
  ];

  nixpkgs.config.allowUnfree = true;
  # Home-manager config
  home-manager.useGlobalPkgs = true;
  home-manager.sharedModules = [
    inputs.caelestia-shell.homeManagerModules.default
    (_: let
      # Upstream sets SETUPTOOLS_SCM_PRETEND_VERSION as a derivation attr, which is not exported
      # as an env var under structuredAttrs, so hatch-vcs fails without a git checkout.
      caelestia-cli = inputs.caelestia-shell.inputs.caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs {
        preBuild = "export SETUPTOOLS_SCM_PRETEND_VERSION=1";
      };
    in {
      home.packages = with pkgs; [
        # pokego # Overlayed
        # krita
        # gimp
        obsidian
        bitwarden-desktop
        brave
        gnome-network-displays
        proton-vpn
        zoom-us
        pi-coding-agent
        claude-code
        cursor-cli

        tor
        tor-browser
        monero-gui
        parted
        efibootmgr

        logiops
      ];

      # enable cursor, the old fashioned way
      programs.cursor.enable = true;

      programs.caelestia = {
        enable = true;
        package = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
          withCli = true;
          inherit caelestia-cli;
        };
        systemd = {
          enable = true;
          target = "graphical-session.target";
          environment = [];
        };
        settings = {
          bar.status = {
            showBattery = true;
          };
          paths.wallpaperDir = "~/NixOS/modules/themes/wallpapers-ca";
        };
        cli = {
          enable = true;
          package = caelestia-cli;
          settings = {
            theme.enableGtk = false;
          };
        };
      };
    })
  ];
  # Define system packages here
  environment.systemPackages = with pkgs; [
    krb5
    cifs-utils
    keyutils
    samba
  ];
  system.activationScripts.symlink-requestkey = ''
    if [ ! -d /sbin ]; then
      mkdir /sbin
    fi
    ln -sfn /run/current-system/sw/bin/request-key /sbin/request-key
  '';
  # request-key expects a configuration file under /etc
  environment.etc."request-key.conf" = lib.mkForce {
    text = let
      upcall = "${pkgs.cifs-utils}/bin/cifs.upcall";
      keyctl = "${pkgs.keyutils}/bin/keyctl";
    in ''
      #OP     TYPE          DESCRIPTION  CALLOUT_INFO  PROGRAM
      # -t is required for DFS share servers...
      create  cifs.spnego   *            *             ${upcall} -t %k
      create  dns_resolver  *            *             ${upcall} %k
      # Everything below this point is essentially the default configuration,
      # modified minimally to work under NixOS. Notably, it provides debug
      # logging.
      create  user          debug:*      negate        ${keyctl} negate %k 30 %S
      create  user          debug:*      rejected      ${keyctl} reject %k 30 %c %S
      create  user          debug:*      expired       ${keyctl} reject %k 30 %c %S
      create  user          debug:*      revoked       ${keyctl} reject %k 30 %c %S
      create  user          debug:loop:* *             |${pkgs.coreutils}/bin/cat
      create  user          debug:*      *             ${pkgs.keyutils}/share/keyutils/request-key-debug.sh %k %d %c %S
      negate  *             *            *             ${keyctl} negate %k 30 %S
    '';
  };
  networking = {
    hostName = hostname;

    firewall.allowedTCPPorts = [3306 5173 8088];
    firewall.allowedUDPPorts = [5173 8088];

    networkmanager.wifi.scanRandMacAddress = false;
    networkmanager.plugins = [
      pkgs.networkmanager-openconnect
      pkgs.networkmanager-openvpn
    ];
  };
  # No local shares or media library are configured on this laptop.
  services.samba.enable = false;
  services.nfs.server.enable = false;
  services.minidlna.enable = false;
  services.upower.enable = true;
  # virtualisation.docker = {
  #   enable = true;
  # };
  users.users.zak.extraGroups = ["docker"];
}
