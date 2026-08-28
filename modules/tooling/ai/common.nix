{ lib, pkgs, ... }:

{
  programs.mcp = {
    enable = true;
    servers = {
      chrome-devtools = {
        command = "npx";
        args = [
          "-y"
          "chrome-devtools-mcp@latest"
        ];
      };
      nix = {
        command = "uvx";
        args = [ "mcp-nixos" ];
      };
      nushell = {
        command = "nu";
        args = [ "--mcp" ];
      };
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      # metavr ships binaries only for macOS and Windows, not Linux.
      metavr = {
        command = "npx";
        args = [
          "-y"
          "metavr"
          "mcp"
          "server"
        ];
      };
    };
  };
}
