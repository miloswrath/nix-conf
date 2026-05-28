{
  pkgs,
  wallpaper,
  ...
}: let
  nordic-pkg = pkgs.nordic;
in {
  home-manager.sharedModules = [
    ({config, ...}: {
      home.packages = [nordic-pkg];

      qt = {
        enable = true;
        platformTheme.name = "gtk";
        style.name = "Nordic";
      };
      gtk = {
        enable = true;
        theme = {
          name = "Nordic";
          package = pkgs.nordic;
        };
        iconTheme = {
          # package = pkgs.adwaita-icon-theme;
          # name = "Adwaita";
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
        gtk3.extraConfig = {
          "gtk-application-prefer-dark-theme" = "1";
        };
        gtk4.extraConfig = {
          "gtk-application-prefer-dark-theme" = "1";
        };
      };

      # Set wallpaper
 #    services.hyprpaper = {
 #      enable = true;
 #      settings = {
 #        preload = ["${../wallpapers/${wallpaper}.jxl}"];
 #        wallpaper = [",${../wallpapers/${wallpaper}.jxl}"];
 #      };
 #    };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };

      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      xdg.configFile = {
        "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
        "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
        "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
        "Kvantum/Nordic".source = "${nordic-pkg}/share/Kvantum/Nordic";
        "Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
          General.theme = "Nordic";
        };
      };
    })
  ];
}
