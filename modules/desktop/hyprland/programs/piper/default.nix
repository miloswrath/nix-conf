{
  lib,
  pkgs,
  ...
}: let
  # G502 X Plus needs libratbag git master (post-0.18):
  #   - HIDPP20_ONBOARD_PROFILES_PROFILE_TYPE_G502X (0x05) added in 65d07ae4
  #   - HIDPP20_QUIRK_G502X_PLUS (LED slot offset) same commit
  # 0.18 hits "Profile layout not supported: 0x05" and bails.
  #
  # Wireless ID: 046d:4099 (logical device on the Lightspeed receiver, not the receiver's
  # own hardware ID 046d:c547 which libratbag never matches directly).
  libratbag = pkgs.libratbag.overrideAttrs (_: {
    version = "0-unstable-2026-04-25";
    src = pkgs.fetchFromGitHub {
      owner = "libratbag";
      repo = "libratbag";
      rev = "805e7fb77fb90dc5680aba39c710106c4b01f897";
      hash = "sha256-k02GHn9a9xbdAXDuhEoBaunmz9XtijDldrAT78/xlKo=";
    };
  });

  # 0.8 release is missing logitech-g502-x-plus.svg; added in git master.
  piper = pkgs.piper.overrideAttrs (_: {
    version = "0-unstable-2026-04-25";
    src = pkgs.fetchFromGitHub {
      owner = "libratbag";
      repo = "piper";
      rev = "ff75616c5c4fa6173692040b2246bcfee55bd1c3";
      hash = "sha256-0Rt/ere8kd3vYgouTPJwLy1D4VwEukDCiaR0wxOMhKk=";
    };
  });
in {
  services.ratbagd = {
    enable = true;
    package = libratbag;
  };

  home-manager.sharedModules = [
    (_: {
      home.packages = [ piper ];
    })
  ];
}
