{ pkgs, ... }:

let
  codexConfig = (pkgs.formats.toml { }).generate "codex-system-config" {
    mcp_servers = {
      github = {
        url = "https://api.githubcopilot.com/mcp/";
        bearer_token_env_var = "GITHUB_TOKEN";
      };
      nix = {
        command = "uvx";
        args = [ "mcp-nixos" ];
      };
      nushell = {
        command = "nu";
        args = [ "--mcp" ];
      };
    };
  };
in
{
  environment.etc."codex/config.toml".source = codexConfig;
}
