{ pkgs, ... }:

{
  # Zed discovers reusable skills from ~/.agents/skills. Keep the JJ workflow
  # shared with the other configured agent clients rather than duplicating it.
  home.file = {
    ".agents/skills/jj".source = ../../../.agents/skills/jj;
    ".agents/skills/jj-flake-evolution".source =
      ../../../copilot/plugins/jj-flake-vigilance/skills/jj-flake-evolution;
  };

  programs.zed-editor = {
    enable = true;
    userSettings = {
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
