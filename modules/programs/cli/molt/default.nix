{ inputs, lib, ... }:

let
  hasClawdbot = inputs ? nix-clawdbot;
in
{
  assertions = [
    {
      assertion = hasClawdbot;
      message = "Missing nix-clawdbot input; add it to flake.nix inputs to enable molt.";
    }
  ];

  nixpkgs.overlays = lib.optionals hasClawdbot [
    inputs.nix-clawdbot.overlays.default
  ];

  home-manager.sharedModules = lib.optionals hasClawdbot [
    inputs.nix-clawdbot.homeManagerModules.clawdbot
    ({ pkgs, config, ... }: {
      programs.clawdbot = {
        enable = true;
        documents = ../../../../clawdocuments;
        instances.default = {
          enable = true;
          configOverrides = {
            channels.discord.accounts.main = {
              enabled = true;
              allowBots = false;
              dm = {
                enabled = false;
                policy = "disabled";
              };
            };
          };
        };
        firstParty = {
          summarize.enable = false;
          peekaboo.enable = false;
        };
      };

      home.activation = {
        clawdbotDirs = lib.mkForce (inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${pkgs.coreutils}/bin/mkdir -p ${config.programs.clawdbot.stateDir} ${config.programs.clawdbot.workspaceDir} /tmp/clawdbot
        '');
        clawdbotConfigFiles = lib.mkForce (inputs.home-manager.lib.hm.dag.entryAfter [ "clawdbotDirs" ] ''
          ${pkgs.coreutils}/bin/true
        '');
      };
    })
  ];
}
