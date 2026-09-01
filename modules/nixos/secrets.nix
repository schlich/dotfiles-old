{ ... }:

{
  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.github-token = {
      file = ../../secrets/github-token.age;
      owner = "schlich";
      group = "users";
      mode = "0400";
    };
  };
}
