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
