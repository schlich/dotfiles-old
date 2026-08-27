{ inputs, pkgs, ... }:

{
  imports = [ ./common.nix ];

  programs.codex = {
    enable = true;
    skills = {
      immersive-songwriting-studio = ../../../copilot/skills/immersive-songwriting-studio;
      gh-stack = "${inputs.gh-stack}/skills/gh-stack";
      grill-me = "${inputs.grill-me}/.agents/skills/grill-me";
      jj = ../../../copilot/skills/jj;
      trunk-based-jj = ../../../copilot/skills/trunk-based-jj;
      marimo-pair = "${inputs.marimo-pair}/skills/marimo-pair";
      nu = ../../../copilot/skills/nushell;
      hz-immersive-designer = "${inputs.meta-quest-agentic-tools}/skills/hz-immersive-designer";
      hz-iwsdk-webxr = "${inputs.meta-quest-agentic-tools}/skills/hz-iwsdk-webxr";
      hz-new-project-creation = "${inputs.meta-quest-agentic-tools}/skills/hz-new-project-creation";
      hz-quest-verify-first = "${inputs.meta-quest-agentic-tools}/skills/hz-quest-verify-first";
      hz-store-pwa = "${inputs.meta-quest-agentic-tools}/skills/hz-store-pwa";
      hz-vr-debug = "${inputs.meta-quest-agentic-tools}/skills/hz-vr-debug";
      metavr-cli = "${inputs.meta-quest-agentic-tools}/skills/metavr-cli";
    };
  };

  home.file = {
    ".codex/agents/jj-flake-vigilance-specialist.toml".text = ''
      name = "jj_flake_vigilance_specialist"
      description = "Specialist for JJ-first, validation-heavy Nix flake changes in schlich/dotfiles."
      model = "gpt-5.6"
      model_reasoning_effort = "high"
      developer_instructions = """
      Handle Nix flake changes in schlich/dotfiles with JJ-first version control discipline.

      Inspect the current workspace before editing. Use JJ, not mutating Git, for repository writes. Preserve unrelated changes. Before risky JJ history operations, create a checkpoint with copilot/skills/jj/scripts/jj-checkpoint.

      Keep the existing modular flake structure. Format Nix edits with nix fmt and validate home-level changes with nix build .#homeConfigurations.schlich.activationPackage; validate system-level changes with nix build .#nixosConfigurations.asus.config.system.build.toplevel. Do not activate configurations unless requested.

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
