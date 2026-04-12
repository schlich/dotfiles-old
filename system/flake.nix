{
  description = "evilcorp";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      dms,
      nixos-wsl,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "26.05";
            wsl.enable = true;
            wsl.defaultUser = "schlich";
            wsl.docker-desktop.enable = true;
            wsl.startMenuLaunchers = true;
            wsl.useWindowsDriver = true;
          }
          dms.nixosModules.dank-material-shell
          dms.nixosModules.greeter
          ./configuration.nix
        ];
      };
    };
}
