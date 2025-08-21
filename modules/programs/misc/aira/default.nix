{ pkgs, lib, ... }:
let
  airi = pkgs.stdenv.mkDerivation {
    pname = "airi";
    version = "0.7.1";

    src = pkgs.fetchzip {
      url = "https://github.com/moeru-ai/airi/archive/refs/tags/v0.7.1.tar.gz";
      sha256 = "sha256-Y2Lkm+lgtgkv9BuIKG48TnzPmyC1UlYvr13EVb6K3Q0=";
    };

    # Tooling
    nativeBuildInputs = with pkgs; [
      nodejs_20 pnpm python3Minimal pkg-config esbuild
    ];

    # Stop common downloads inside sandbox
    CI = "1";
    NODE_ENV = "production";
    PUPPETEER_SKIP_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    ESBUILD_BINARY_PATH = "${pkgs.esbuild}/bin/esbuild";

    buildPhase = ''
      set -x
      runHook preBuild
      export HOME="$TMPDIR"
      pnpm config set store-dir "$TMPDIR/pnpm-store"

      pnpm install --frozen-lockfile

      # Build only the web workspace (adjust selector to match the repo)
      pnpm --filter web... run build \
        || pnpm --filter @airi/web... run build \
        || pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      DIST_DIR=dist
      mkdir -p "$out/share/$pname"
      if [ -d "$DIST_DIR" ]; then
        cp -r "$DIST_DIR"/* "$out/share/$pname/"
      elif [ -d packages/app/dist ]; then
        cp -r packages/app/dist/* "$out/share/$pname/"
      else
        echo "No dist found. Adjust DIST_DIR." >&2
        exit 1
      fi

      mkdir -p "$out/bin"
      cat > "$out/bin/$pname" <<'SH'
      #!@shell@
      set -euo pipefail
      cd "$(dirname "$(readlink -f "$0")")/../share/airi"
      echo "Serving AIRI at http://127.0.0.1:5173"
      exec @py@ -m http.server 5173
      SH
      substituteInPlace "$out/bin/$pname" \
        --replace '@shell@' "${pkgs.runtimeShell}" \
        --replace '@py@'    "${pkgs.python3Minimal}/bin/python"
      chmod +x "$out/bin/$pname"
      runHook postInstall
    '';
  }; in {
  home-manager.sharedModules = [
    (_: {
      home.packages = [ airi ];
      xdg.desktopEntries.airi = {
        name = "AIRI (local)";
        comment = "Serve the AIRI static build";
        exec = "airi";
        terminal = false;
        type = "Application";
        categories = [ "Network" "Utility" ];
      };
    })
  ];
}

