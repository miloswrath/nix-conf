{
  lib,
  pkgs,
  config,
  ...
}: let
  nvidiaDriverChannel = config.boot.kernelPackages.nvidiaPackages.latest; # stable, latest, beta, etc.
in {
  environment.sessionVariables = lib.optionalAttrs config.programs.hyprland.enable {
    NVD_BACKEND = "direct";
    GBM_BACKEND = "nvidia-drm";
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    VDPAU_DRIVER = "va_gl";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # MOZ_DISABLE_RDD_SANDBOX = 1; # Potential security risk

    __GL_GSYNC_ALLOWED = "1"; # GSync
    NIXOS_OZONE_WL = "1"; # this ensures that wayland is used for ozone 
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"]; # or "nvidiaLegacy470", etc.
  boot.kernelParams = lib.optionals (lib.elem "nvidia" config.services.xserver.videoDrivers) [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  hardware = {
    nvidia = {
      open = true;
      # nvidiaPersistenced = true;
      nvidiaSettings = true;
      powerManagement.enable = true; # This can cause sleep/suspend to fail.
      modesetting.enable = true;
      #package = nvidiaDriverChannel;
      package = pkgs.linuxPackages_latest.nvidiaPackages.latest;
    };
    graphics = {
      enable = true;
      #package = nvidiaDriverChannel;
      package = pkgs.linuxPackages_latest.nvidiaPackages.latest;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
        egl-wayland
      ];
    };
  };
  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "cudatoolkit"
        "nvidia-persistenced"
        "nvidia-settings"
        "nvidia-x11"
        "nvidia-kernel"
        "nvidia-dkms"
        "nvidia-modprobe"
        "nvidia-vaapi-driver"
        "vaapiVdpau"
        "libGL"
        "libEGL"
      ];
  };
  nix.settings = {
    substituters = ["https://cuda-maintainers.cachix.org"];
    trusted-public-keys = ["cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="];
  };
}
