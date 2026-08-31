{ inputs, pkgs, ... }:

let
  skills = import ./shared-skills.nix { inherit inputs; };
in

{
  imports = [ ./common.nix ];

  programs.codex = {
    enable = true;
    inherit skills;
  };

  home.file = {
    ".codex/AGENTS.md" = {
      force = true;
      text = ''
        # Shell conventions

        The user's interactive and configured automation shell is Nushell. When
        producing a user-facing shell command, IntelliShell template, alias, or
        script, use valid Nushell syntax.

        - Use `;` to run commands sequentially. Do not use Bash operators such
          as `&&` or `||` unless deliberately invoking a POSIX shell.
        - When a subsequent command must depend on an external command's exit
          status, use Nushell control flow and `complete`; do not emulate it
          with Bash chaining.
        - A tool invocation may use its own execution shell, but never copy that
          shell's syntax into a command intended for the user's Nushell prompt.
        - Before saving a multi-command IntelliShell template, validate it with
          `nu -c` when practical.
      '';
    };
    ".codex/agents/jj-flake-vigilance-specialist.toml".text = ''
      name = "jj_flake_vigilance_specialist"
      description = "Specialist for JJ-first, validation-heavy Nix flake changes in schlich/dotfiles."
      model = "gpt-5.6"
      model_reasoning_effort = "high"
      developer_instructions = """
      Handle Nix flake changes in schlich/dotfiles with JJ-first version control discipline.

      Inspect the current workspace before editing. Use JJ, not mutating Git, for repository writes. Preserve unrelated changes. Before risky JJ history operations, create a checkpoint with .agents/skills/jj/scripts/jj-checkpoint.

      Keep the existing modular flake structure. Target only x86_64-linux for all flake outputs unless explicitly asked for more. Format Nix edits with nix fmt and validate NixOS changes with nix build .#nixosConfigurations.asus.config.system.build.toplevel.

      When Nix configuration edits are ready to apply, identify whether they affect the NixOS system, Home Manager, or both, and ask the user for explicit approval before activating anything. For NixOS changes, offer sudo nixos-rebuild switch --flake .#asus; never run it automatically. Home Manager is embedded in the asus NixOS configuration, so do not use standalone home-manager switch. Use home-activate for a home-only activation without sudo. It does not apply system-owned changes, including home.packages because home-manager.useUserPackages = true.

      When publication is requested, use jj-ci publish --auto-merge after validation. Let GitHub required checks and auto-merge deliver the change to main. Keep explanations concise and behavior-focused.
      """
    '';
    ".codex/agents/jj-trunk-triage.toml".text = ''
      name = "jj_trunk_triage"
      description = "Lightweight read-only triage for JJ trunk status, PR checks, stack state, and formatting-only corrections."
      model = "gpt-5.6-luna"
      model_reasoning_effort = "medium"
      sandbox_mode = "read-only"
      developer_instructions = """
      Use this agent for read-only status, PR and CI summaries, stack inspection, and formatting-only corrections. Do not mutate JJ history, resolve conflicts, publish or merge pull requests, link or merge stacks, or make credentialed GitHub writes. Report actionable state to the parent agent.
      """
    '';
  };

  dotfiles.tooling.ai.codex = {
    command = "${pkgs.codex}/bin/codex";
    automation = ''
      ^${pkgs.codex}/bin/codex exec --dangerously-bypass-approvals-and-sandbox $prompt
    '';
  };
}
