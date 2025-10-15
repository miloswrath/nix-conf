{pkgs, ...}: {
  home-manager.sharedModules = [
    ({pkgs, ...}: {
      home.packages = with pkgs; [openconnect];
    })
  ];
}
