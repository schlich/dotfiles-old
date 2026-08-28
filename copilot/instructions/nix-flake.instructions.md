---
description: 'Nix flake conventions and guidelines'
applyTo: '**/*.nix'
---

# Nix Flake Guidelines

Conventions and rules for authoring, modifying, and maintaining Nix flakes and Nix expressions.

## Architecture and System Targeting

- **Target only `x86_64-linux`** for all flake outputs (`packages`, `devShells`, `checks`, `formatter`, `apps`, `nixosConfigurations`, `homeConfigurations`, etc.) unless explicitly asked to support additional architectures or platforms.
- Do not introduce multi-system flake helpers (such as `flake-utils` or complex multi-system matrices) unless explicitly requested.
- Keep system-specific derivations and outputs pinned directly to `x86_64-linux`.

## Flake Structure and Modularity

- Keep tooling, shell wrappers, agent assets, and workflow enablement declarative through `flake.nix`, `home.nix`, and `modules/`.
- Preserve the existing modular flake structure. Avoid introducing the Dendritic Pattern as part of an unrelated change; adopting it requires a deliberate architecture migration.
- Add user packages in `modules/home/packages.nix`, version-control wrappers in `modules/programs/vcs.nix`, and AI client configuration in `modules/tooling/ai/` and `modules/programs/`.

## Formatting and Validation

- Format all Nix changes with `nix fmt` (`nixfmt-tree`).
- Validate changes by building the smallest relevant target:
  - Home Manager changes: `nix build .#homeConfigurations.schlich.activationPackage`
  - NixOS system changes: `nix build .#nixosConfigurations.asus.config.system.build.toplevel`
