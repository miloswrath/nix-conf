{
  inputs,
  lib,
  ...
}: {
  # allow spotify to be installed if you don't have unfree enabled already
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
    ];
  home-manager.sharedModules = [
    ({pkgs, ...}: let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in {
      # import the flake's module for your system
      imports = [inputs.spicetify-nix.homeManagerModules.default];

      # configure spicetify :)
      programs.spicetify = {
        enable = true;
        wayland=true;
        theme = spicePkgs.themes.catppuccin;
        colorScheme = "mocha";
        enabledExtensions = with spicePkgs.extensions; [
          adblock
          shuffle # shuffle+ (special characters are sanitized out of ext names)
          keyboardShortcut # vimium-like navigation
          copyLyrics # copy lyrics with selection
          fullAppDisplay
          # autoVolume
          # showQueueDuration
          # hidePodcasts
        ];
        enabledCustomApps = with spicePkgs.apps; [
        lyricsPlus
        ncsVisualizer
        #   reddit
        #   marketplace
        #   localFiles
        ];
      };
    })
  ];
}
