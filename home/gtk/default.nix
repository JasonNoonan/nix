{ pkgs, lib, config, ... }:

{
  dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Colloid-Dark-Catppuccin";
        package = pkgs.colloid-gtk-theme.override {
          themeVariants = [ "default" "purple" "teal" "grey" "green" ];
          tweaks = [ "catppuccin" "rimless" "normal" ];
        };
      };

      cursorTheme = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
      };

      iconTheme = {
        name = "Fluent-dark";
        package = pkgs.fluent-icon-theme;
      };
    };
}
