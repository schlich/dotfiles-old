{
  description = "Modular Home Manager and NixOS configuration";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    paseo = {
      url = "github:getpaseo/paseo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nuenv.url = "https://flakehub.com/f/xav-ie/nuenv/*.tar.gz";
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    marimo-pair = {
      url = "github:marimo-team/marimo-pair";
      flake = false;
    };
    marimo-skills = {
      url = "github:marimo-team/skills";
      flake = false;
    };
    gh-stack = {
      url = "github:github/gh-stack";
      flake = false;
    };
    grill-me = {
      url = "github:udecode/plate";
      flake = false;
    };
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    jj-starship = {
      url = "github:dmmulroy/jj-starship";
    };
    niri = {
      url = "github:epireyn/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
    archify = {
      url = "github:tt-a1i/archify";
      flake = false;
    };
    meta-quest-agentic-tools = {
      url = "github:meta-quest/agentic-tools";
      flake = false;
    };
  };

  outputs =
    inputs@{
      home-manager,
      determinate,
      agent-skills,
      anthropic-skills,
      nixpkgs,
      fh,
      jj-starship,
      nuenv,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = [
        jj-starship.overlays.default
        nuenv.overlays.nuenv
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
      mkNixos =
        modules:
        lib.nixosSystem {
          inherit system modules;
          specialArgs = { inherit inputs; };
        };
      internalNvmeMigration = pkgs.writeShellApplication {
        name = "internal-nvme-migration";
        runtimeInputs = with pkgs; [
          btrfs-progs
          coreutils
          cryptsetup
          dosfstools
          efibootmgr
          findutils
          gawk
          gnugrep
          gptfdisk
          nixos-install-tools
          p7zip
          parted
          rsync
          systemd
          util-linux
        ];
        text = builtins.readFile ./scripts/internal-nvme-migration.sh;
      };
      mkAsus =
        storageModule:
        mkNixos [
          determinate.nixosModules.default
          home-manager.nixosModules.home-manager
          inputs.noctalia-greeter.nixosModules.default
          inputs.niri.nixosModules.niri
          # inputs.ragenix.nixosModules.default
          ./configuration.nix
          storageModule
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs;
                username = "schlich";
                homeDirectory = "/home/schlich";
                stateVersion = "26.05";
              };
              users.schlich = import ./home.nix;
            };
            nixpkgs.overlays = overlays;
            environment.systemPackages = [
              fh.packages.x86_64-linux.default
              pkgs.jj-starship
              internalNvmeMigration
            ];
          }
        ];

      nixosConfigurations = {
        asus = mkAsus ./hosts/asus/storage-internal.nix;
        asus-usb = mkAsus ./hosts/asus/hardware-configuration.nix;
      };

      homeCheck = pkgs.linkFarm "home-manager-check" (
        [
          {
            name = "activation";
            path = nixosConfigurations.asus.config.home-manager.users.schlich.home.activationPackage;
          }
        ]
        ++ lib.mapAttrsToList (checkName: path: {
          name = checkName;
          inherit path;
        }) nixosConfigurations.asus.config.home-manager.users.schlich.dotfiles.tooling.checks
      );
    in
    {
      inherit nixosConfigurations;

      templates.default = {
        path = ./templates/default;
        description = "Nushell and Jujutsu project starter";
        welcomeText = ''
          # Project initialized

          Run `direnv allow` or `nix develop`, then replace the placeholder
          project metadata and add the language-specific tools you need.
        '';
      };

      packages.${system} = {
        default = nixosConfigurations.asus.config.system.build.toplevel;
        internal-nvme-migration = internalNvmeMigration;
      };

      apps.${system}.internal-nvme-migration = {
        type = "app";
        program = "${internalNvmeMigration}/bin/internal-nvme-migration";
      };

      formatter.${system} = pkgs.nixfmt-tree;

      checks.${system} = {
        home-manager-nixos = homeCheck;
        niri-config =
          pkgs.runCommand "niri-config-check"
            {
              nativeBuildInputs = [ pkgs.niri ];
            }
            ''
              niri validate --config ${./niri/config.kdl}
              touch "$out"
            '';
        zellij-config =
          pkgs.runCommand "zellij-config-check"
            {
              nativeBuildInputs = [ pkgs.zellij ];
            }
            ''
              config_dir="$TMPDIR/zellij"
              mkdir -p "$config_dir/layouts"
              cp ${./zellij/config.kdl} "$config_dir/config.kdl"
              cp ${./zellij/layouts/default.kdl} "$config_dir/layouts/default.kdl"
              ZELLIJ_CONFIG_DIR="$config_dir" zellij setup --check
              touch "$out"
            '';
        whitespace =
          pkgs.runCommand "whitespace-check"
            {
              nativeBuildInputs = [ pkgs.git ];
              src = ./.;
            }
            ''
              set +e
              git --no-pager diff --check --no-index --no-patch /dev/null "$src"
              status=$?
              set -e
              test "$status" -eq 1
              touch "$out"
            '';
      };
    };
  nixConfig = {
    extra-substituters = [
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
    trusted-users = [ "schlich" ];
  };
}
