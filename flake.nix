{
  description = "Modular Home Manager and NixOS configuration";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
    };
    nixgl.url = "github:nix-community/nixGL";
    nuenv.url = "https://flakehub.com/f/xav-ie/nuenv/*.tar.gz";
    nix-inspect.url = "github:bluskript/nix-inspect";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-docs-mcp = {
      url = "github:christian-blades-cb/rust-docs-mcp/2d69d7acd57a36456f844df45e8aade257352257";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jj-starship = {
      url = "gitlab:lanastara_foss/starship-jj";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # dms = {
    #   url = "github:AvengeMedia/DankMaterialShell/stable";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixos-wsl,
      determinate,
      nixgl,
      nix-inspect,
      jj-starship,
      # dms,
      niri,
      agenix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          jj-starship.overlays.default
        ];
      };
    in
    {
      # nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      #   specialArgs = { inherit inputs; };
      #   modules = [
      #     nixos-wsl.nixosModules.wsl
      #     determinate.nixosModules.default
      #     {
      #       nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      #       environment.systemPackages = [
      #         nix-inspect.packages.${system}.default
      #       ];
      #       nixpkgs.system = system;
      #       programs.nix-ld.enable = true;
      #     }
      #     ./configuration.nix
      #     agenix.nixosModules.default
      #   ];
      # };

      homeConfigurations.schlich = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          niri.homeModules.niri
          ./noctalia.nix
          # dms.homeModules.dank-material-shell
          # dms.homeModules.niri
        ];
        extraSpecialArgs = { inherit inputs nixgl; };
      };

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
