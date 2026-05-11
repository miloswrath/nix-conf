{ ... }: 
{
  home-manager.sharedModules = [
    ({ pkgs, config, ... }: {
      programs.opencode = {
        package = pkgs.opencode;
        enable = true;
      };
    })
  ];
}
