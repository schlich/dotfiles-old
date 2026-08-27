{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  basePackage = inputs.codex-desktop-linux.packages.${pkgs.stdenv.hostPlatform.system}.default;
  desktopPackage = pkgs.symlinkJoin {
    name = "${basePackage.name}-with-bubblewrap";
    paths = [ basePackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -f "$out/bin/codex-desktop"
      makeWrapper "${basePackage}/bin/codex-desktop" "$out/bin/codex-desktop" \
        --prefix PATH : "${lib.makeBinPath [ pkgs.bubblewrap ]}"

      desktopFile="$out/share/applications/codex-desktop.desktop"
      rm -f "$desktopFile"
      substitute "${basePackage}/share/applications/codex-desktop.desktop" "$desktopFile" \
        --replace-fail "${basePackage}/bin/codex-desktop" "$out/bin/codex-desktop" \
        --replace-fail "${basePackage}/share/applications/codex-desktop.desktop" "$desktopFile"
    '';
    meta = basePackage.meta;
  };
in
{
  imports = [ inputs.codex-desktop-linux.homeManagerModules.default ];

  programs.codexDesktopLinux = {
    enable = true;
    package = desktopPackage;
  };
}
