{ pkgs, ... }:

{
  # Zed discovers reusable skills from ~/.agents/skills. Keep the JJ workflow
  # shared with the other configured agent clients rather than duplicating it.
  home.file = {
    ".config/zed/AGENTS.md".text = ''
      # Jujutsu

      Do not invoke `jj` in interactive mode. Use only non-interactive invocations,
      supplying every required argument or message flag explicitly.
    '';
    ".agents/skills/jj".source = ../../../.agents/skills/jj;
    ".agents/skills/jj-flake-evolution".source =
      ../../../copilot/plugins/jj-flake-vigilance/skills/jj-flake-evolution;
    ".agents/skills/nushell".source = ../../../.agents/skills/nushell;
    ".agents/skills/nushell-plugin-builder".source = ../../../.agents/skills/nushell/plugin-builder;
    ".agents/skills/nushell-text-processing".source = ../../../.agents/skills/nushell/text-processing;
  };

  programs.zed-editor = {
    enable = true;
    userSettings = {
      # This covers Zed's built-in terminal and task runner. ACP agent tool
      # shells are selected independently by Zed and currently cannot be
      # overridden through its settings.
      terminal.shell.program = "${pkgs.nushell}/bin/nu";

      agent_servers.codex-acp = {
        type = "registry";
        favorite_config_option_values.collaboration_mode = [ "default" ];
        default_config_options.collaboration_mode = "default";
      };

      agent = {
        sandbox_permissions = {
          allow_unsandboxed = true;
          allow_fs_write_all = true;
        };
        default_model = {
          provider = "zed.dev";
          model = "gpt-5.6-sol";
          enable_thinking = true;
          effort = "medium";
        };
        favorite_models = [ ];
        model_parameters = [ ];
      };
    };
  };

  dotfiles.tooling.editors.zed.command = "${pkgs.zed-editor}/bin/zeditor";
}
