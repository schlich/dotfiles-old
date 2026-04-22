{ pkgs, inputs, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  users.defaultUserShell = pkgs.nushell;
  users.users.schlich.shell = pkgs.nushell;

  wsl = {
    enable = true;
    defaultUser = "schlich";
    useWindowsDriver = true;
    ssh-agent.enable = true;
    startMenuLaunchers = true;
  };

  environment = {
    shells = [ pkgs.nushell ];
    variables = {
      EDITOR = "hx";
      VISUAL = "hx";
      # WSLg uses Mesa's D3D12 backend, so adapter selection happens by name.
      # MESA_D3D12_DEFAULT_ADAPTER_NAME = "Intel(R) UHD Graphics 620";
      # LIBVA_DRIVER_NAME = "d3d12";
      # GALLIUM_DRIVER = "d3d12";
      # LD_LIBRARY_PATH = "/usr/lib/wsl/lib";
    };
    systemPackages = [
      pkgs.wget
      inputs.agenix.packages.x86_64-linux.default
    ];
  };

  system.stateVersion = "26.05";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ mesa ];
    enable32Bit = true;
  };
  services.dbus.implementation = "broker";
  programs = {
    nix-ld.enable = true;
  };

}
