{ ... }:

{
  imports = [ ./hardware-common.nix ];

  boot.loader.limine.efiInstallAsRemovable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b1409dcc-54c2-4f90-8712-3c52aff50c20";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9FBB-AFFB";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];
}
