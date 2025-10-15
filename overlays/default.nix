{
  inputs,
  settings,
  ...
}: {
  additions = final: _prev:
    import ../pkgs {
      pkgs = final;
      settings = settings;
    };

  modifications = final: _prev: {
    nur = inputs.nur.overlays.default;

    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
