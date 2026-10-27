{pkgs, ...}: {
  home-manager.sharedModules = [
  (_: {
    home.packages = with pkgs; [
        microsoft-edge
        teams-for-linux
      ];
    })
  ];
}
