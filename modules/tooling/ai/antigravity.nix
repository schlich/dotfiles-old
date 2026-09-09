{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  programs.antigravity = {
    enable = true;
    package = pkgs.antigravity-ide;
  };

  programs.antigravity-cli.enable = true;
}
