let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEHY5jf0ph93vgzayvM9SYaSTTd7hMiw+MrxxXT1I3Wu user-key";
  host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFA2Wd/hVlqxzgbbJS6ogkbMDj0Anq4xlMKLPKDdvmAs root@nixos";
in
{
  "openai.age".publicKeys = [
    user
    host
  ];
}
