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

  modifications = final: prev: {
    # Upstream NUR overlay (kept as-is)
    nur = inputs.nur.overlays.default;

    # --- Shim: provide a replacement for removed llvmPackages_17 ---
    # This unblocks any downstream package that still references llvmPackages_17.
    llvmPackages_17 = final.llvmPackages_19;

    # Pin a stable nixpkgs set (usable as final.stable.<pkg>)
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config = { allowUnfree = true; };
    };

    # Example local package exposed via overlay
    cisco-anyconnect = (import ./anyconnect.nix) {
      inherit final settings inputs;
    };
  };
}

