{...}: {
  home-manager.sharedModules = [
    (_: {
      programs.codex = {
        enable = true;
      };
    })
  ];
}
