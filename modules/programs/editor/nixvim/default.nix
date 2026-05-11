{
  inputs,
  pkgs,
  ...
}: {
  home-manager.sharedModules = [
    (_: {
      home.packages = with pkgs; [
        inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    })
  ];
}
