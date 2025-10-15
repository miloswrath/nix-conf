# Repository Guidelines
This repository defines the reproducible NixOS system for Zak's machines plus reusable templates for development environments. Use the guidance below when extending the configuration.

## Project Structure & Module Organization
- `flake.nix` centralises upstream inputs, shared `settings`, overlays, and exposes the `Default` host.
- `hosts/` contains machine profiles (see `hosts/Default/`) and shared base options in `hosts/common.nix`; duplicate the folder when onboarding new hardware.
- `modules/` is organised by domain (`hardware`, `desktop`, `programs`, `themes`, `scripts`); each `default.nix` module is imported from host configs.
- `pkgs/` houses custom packages and themed assets surfaced through `overlays/default.nix`.
- `dev-shells/` provides flake templates for language-specific dev shells; run `nix flake init -t .#rust` (or another name) to scaffold a project.

## Build, Test, and Development Commands
- `nixos-rebuild test --flake .#Default` builds the system and boots it in a disposable generation.
- `nixos-rebuild switch --flake .#Default` deploys the configuration after validation.
- `nix build .#nixosConfigurations.Default.config.system.build.toplevel` checks that the derivation evaluates without applying it.
- `nix flake check` runs evaluations and formatting; run it before pushing.
- For fresh installs, use `sudo ./install.sh` or `sudo ./live-install.sh` as documented in each script header.

## Coding Style & Naming Conventions
- Format all Nix code with `nix fmt` (Alejandra); keep two-space indentation and align attribute sets and comments like existing modules.
- Name files with lowercase hyphenated words and keep attribute identifiers descriptive (`terminalFileManager`, `sddmTheme`).
- Centralise user-specific defaults in the `settings` attrset instead of hardcoding values inside modules.

## Testing Guidelines
- After changing services, confirm status with `nixos-rebuild test` followed by targeted checks (e.g., `systemctl status minidlna`, `nfsstat -m`).
- When adjusting module imports, re-run `nix flake check` and `nix build .#nixosConfigurations.Default.config.system.build.toplevel` to catch evaluation errors early.
- Document any manual verification steps or hardware dependencies in the corresponding module comments.

## Commit & Pull Request Guidelines
- Follow the repository’s short, present-tense commit style (`made thermal management changes`) and keep one logical change per commit.
- In PRs, describe the motivation, list touched modules/hosts, link any issues, and attach screenshots for UI or theming tweaks.
- Call out post-merge actions (firmware blobs, secret provisioning) so other operators can reproduce the deployment without guesswork.
