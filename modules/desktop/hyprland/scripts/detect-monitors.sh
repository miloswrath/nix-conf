#!/usr/bin/env bash
# look for the two Samsung externals by their EDID desc
if hyprctl monitors \
     | grep -q "Samsung Electric Company S24R35xFZ H4CW602620B" \
  && grep -q "Samsung Electric Company S24R35xFZ H4CW602659B"; then
  ln -sf ~/.config/hypr/monitors-work.conf ~/.config/hypr/monitors.conf
else
  ln -sf ~/.config/hypr/monitors-home.conf ~/.config/hypr/monitors.conf
fi

# reload Hyprland so it picks up the new monitors.conf
hyprctl reload
