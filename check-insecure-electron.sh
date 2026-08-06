#!/usr/bin/env bash
# Checks whether the permittedInsecurePackages entry for electron-40 in your
# NixOS config is still required.
#
# Root cause: vesktop depends on electron-40.x, which is EOL.
# When vesktop upgrades to electron-41+, this permission can be removed.

set -euo pipefail

EOL_MAJOR=40
PACKAGE="nixpkgs#vesktop"

echo "Checking electron version used by ${PACKAGE}..."

DRV_JSON=$(nix show-derivation "$PACKAGE" 2>/dev/null) || {
  echo "ERROR: Could not evaluate vesktop derivation."
  exit 1
}

# Extract the electron version from the makeWrapper call in postFixup,
# which has the form: electron-40.9.2/bin/electron
ELECTRON_VER=$(echo "$DRV_JSON" | grep -oP 'electron-\K\d+\.\d+\.\d+(?=/bin/electron)' | head -1)

if [[ -z "$ELECTRON_VER" ]]; then
  echo "ERROR: Could not parse electron version from vesktop derivation."
  exit 1
fi

MAJOR=$(echo "$ELECTRON_VER" | cut -d. -f1)

echo "vesktop → electron-${ELECTRON_VER}"

if [[ "$MAJOR" -le "$EOL_MAJOR" ]]; then
  echo "Status: still EOL (major ${MAJOR} <= ${EOL_MAJOR})"
  echo "→ Keep permittedInsecurePackages in your NixOS config."
  exit 0
else
  echo ""
  echo "vesktop now uses electron-${ELECTRON_VER} (major ${MAJOR} > ${EOL_MAJOR})."
  echo "The electron-${EOL_MAJOR} entry in permittedInsecurePackages is no longer needed."
  echo "Remove it from hosts/Default/configuration.nix (or wherever you added it)."
  exit 2
fi
