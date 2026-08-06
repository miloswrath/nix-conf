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
      config = {allowUnfree = true;};
    };

    # Keep an explicit unstable package set available and source Qt from it.
    unstable = import inputs.nixpkgs {
      system = final.system;
      config = {allowUnfree = true;};
    };

    qt6 = final.unstable.qt6;
    kdePackages = final.unstable.kdePackages;

    # Keep .NET SDKs on the stable package set.
    dotnet-sdk = final.stable.dotnet-sdk;
    dotnet-sdk_7 = final.stable.dotnet-sdk_7;
    dotnet-sdk_8 = final.stable.dotnet-sdk_8;
    dotnetCorePackages = prev.dotnetCorePackages // {
      dotnet_10 = prev.dotnetCorePackages.dotnet_10 // {
        vmr = prev.dotnetCorePackages.dotnet_10.vmr.overrideAttrs (_: {
          meta = prev.dotnetCorePackages.dotnet_10.vmr.meta // { broken = true; };
        });
      };
    };
    # Example local package exposed via overlay
    cisco-anyconnect = (import ./anyconnect.nix) {
      inherit final settings inputs;
    };

    # nixpkgs bumped glaze 7.9.1 -> 8.0.0 (PR #548864), but Hyprland's
    # CMakeLists still pins `find_package(glaze 7...<8)`, so the build can't
    # find the packaged glaze and falls back to a network FetchContent that
    # fails in the sandbox. Fixed upstream via nixpkgs PR #549253 (relaxes the
    # version constraint), but that hasn't reached the nixos-unstable channel
    # yet. Pin glaze back to the last version satisfying `7...<8` until
    # `nix flake update` picks up the fix, then remove this override.
    glaze = prev.glaze.overrideAttrs (_old: {
      version = "7.9.1";
      src = final.fetchFromGitHub {
        owner = "stephenberry";
        repo = "glaze";
        tag = "v7.9.1";
        hash = "sha256-NRRq5MGF2f5PW0teYnq58ELzson+U6KHVPaY6r30KLA=";
      };
    });
  };
}
