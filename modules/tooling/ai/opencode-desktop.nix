{ pkgs, ... }:

{
  home.packages = [ pkgs.opencode-desktop ];

  xdg.configFile."autostart/opencode-desktop.desktop".source =
    "${pkgs.opencode-desktop}/share/applications/opencode-desktop.desktop";
}
