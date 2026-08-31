{ pkgs, ... }:

{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  accounts.email.accounts.personal = {
    address = "ty.schlich@gmail.com";
    primary = true;
    realName = "Ty Schlichenmeyer";
  };
  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nuenv.writeScriptBin {
      name = "home-activate";
      script = ''
        # Build and activate the Home Manager configuration embedded in NixOS.
        def main [] {
          let flake = "/home/schlich/dotfiles#nixosConfigurations.asus.config.home-manager.users.schlich.home.activationPackage"
          let activation = (^/run/current-system/sw/bin/nix build --no-link --print-out-paths $flake | str trim)

          if ($activation | is-empty) {
            error make { msg: "Nix did not produce a Home Manager activation package." }
          }

          run-external $"($activation)/activate" -- --driver-version 1
        }
      '';
    })
  ];
}
