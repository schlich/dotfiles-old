{ pkgs, inputs, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  users.defaultUserShell = pkgs.nushell;
  users.users.schlich.shell = pkgs.nushell;

  wsl = {
    enable = true;
    defaultUser = "schlich";
    useWindowsDriver = true;
    ssh-enable = true;
  };

  environment = {
    shells = [ pkgs.nushell ];
    variables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };
    systemPackages = [
      pkgs.wget
      inputs.agenix.packages.x86_64-linux.default
    ];
  };

  system.stateVersion = "26.05";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ mesa ];
    enable32Bit = true;
  };
}
