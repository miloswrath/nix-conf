# flake.nix
{
  description = "DevShells to host Ollama locally (CPU, CUDA, ROCm)";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
      f (import nixpkgs {
        inherit system;
        # allowUnfree for CUDA/ROCm libs if you use the gpu shells
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      })
    );
  in {
    devShells = forAllSystems (pkgs: let
      # Common UX bits for all shells
      commonInputs = with pkgs; [ ollama curl jq ];
      commonHook = ''
        # keep models alongside the repo by default
        export OLLAMA_MODELS="$PWD/.ollama"
        mkdir -p "$OLLAMA_MODELS"
        export OLLAMA_ORIGINS=*

        # bind only to localhost by default; change to 0.0.0.0 to serve on LAN
        export OLLAMA_HOST="127.0.0.1:11434"

        echo
        echo "Ollama devshell ready."
        echo "Models dir: $OLLAMA_MODELS"
        echo
        echo "Run server :  ollama serve"
        echo "Test API   :  curl http://$OLLAMA_HOST/api/tags | jq ."
        echo "Pull model :  ollama pull llama3:8b"
        echo "Chat       :  ollama run llama3:8b"
        echo
      '';
    in {
      # ---- 1) CPU-only (works everywhere) ----
      default = pkgs.mkShell {
        buildInputs = commonInputs;
        shellHook = commonHook;
        # Nice extras for CI-ish behavior (some packages try to download stuff)
        OLLAMA_NUM_PARALLEL = "1";
      };

      # ---- 2) NVIDIA / CUDA acceleration ----
      cuda = pkgs.mkShell {
        buildInputs = commonInputs ++ (with pkgs; [
          cudatoolkit
          cudaPackages.cudnn
          cudaPackages.libcublas
          # optional tools:
          nvidia-smi
        ]);
        shellHook = commonHook + ''
          # Make CUDA libs visible to ollama/llama.cpp runtime
          export CUDA_PATH="${pkgs.cudatoolkit}"
          export LD_LIBRARY_PATH="${pkgs.cudatoolkit}/lib:${pkgs.cudaPackages.cudnn}/lib:${pkgs.cudaPackages.libcublas}/lib:$LD_LIBRARY_PATH"
          echo "CUDA enabled shell. Ensure host has proprietary NVIDIA driver loaded."
          nvidia-smi || true
        '';
        OLLAMA_NUM_PARALLEL = "1";
        # Tip: choose which GPU, e.g. export CUDA_VISIBLE_DEVICES=0
      };

      # ---- 3) AMD / ROCm acceleration ----
      rocm = pkgs.mkShell {
        buildInputs = commonInputs ++ (with pkgs; [
          rocmPackages.clr
          rocmPackages.rocm-smi
          # add more rocmPackages if your card/toolchain needs them
        ]);
        shellHook = commonHook + ''
          export ROCM_PATH="${pkgs.rocmPackages.clr}"
          export LD_LIBRARY_PATH="$ROCM_PATH/lib:$LD_LIBRARY_PATH"
          echo "ROCm shell. Ensure amdgpu/ROCm on host matches your GPU."
          rocm-smi || true
          echo "If detection fails, try: export HSA_OVERRIDE_GFX_VERSION=11.0.0 (example)"
        '';
        OLLAMA_NUM_PARALLEL = "1";
      };
    });
  };
}
