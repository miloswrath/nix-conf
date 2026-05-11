{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      codex = prev.codex.overrideAttrs (old: rec {
        version = "0.111.0";

        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.pkg-config ];
        buildInputs = (old.buildInputs or [ ]) ++ [ final.libcap ];

        src = final.fetchFromGitHub {
          owner = "openai";
          repo = "codex";
          tag = "rust-v${version}";
          hash = "sha256-hdR70BhiMg9G/ibLCeHnRSY3PcGZDv0vnqBCbzSRD6I=";
        };

        sourceRoot = "${src.name}/codex-rs";

        cargoDeps = final.rustPlatform.importCargoLock {
          lockFile = "${src}/codex-rs/Cargo.lock";
          outputHashes = {
            "crossterm-0.28.1" = "sha256-6qCtfSMuXACKFb9ATID39XyFDIEMFDmbx6SSmNe+728=";
            "nucleo-0.5.0" = "sha256-Hm4SxtTSBrcWpXrtSqeO0TACbUxq3gizg1zD/6Yw/sI=";
            "ratatui-0.29.0" = "sha256-HBvT5c8GsiCxMffNjJGLmHnvG77A6cqEL+1ARurBXho=";
            "runfiles-0.1.0" = "sha256-uJpVLcQh8wWZA3GPv9D8Nt43EOirajfDJ7eq/FB+tek=";
            "tokio-tungstenite-0.28.0" = "sha256-hJAkvWxDjB9A9GqansahWhTmj/ekcelslLUTtwqI7lw=";
            "tungstenite-0.27.0" = "sha256-AN5wql2X2yJnQ7lnDxpljNw0Jua40GtmT+w3wjER010=";
          };
        };
      });
    })
  ];

  home-manager.sharedModules = [
    ({ pkgs, ... }: {
      home.packages = [ pkgs.codex ];
    })
  ];
}
