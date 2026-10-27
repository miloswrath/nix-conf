{
  lib,
  pkgs,
  config,
  ...
}: let
  nvidiaDriverChannel = config.boot.kernelPackages.nvidiaPackages.stable; # stable, latest, beta, etc.
in {
  environment.sessionVariables = lib.optionalAttrs config.programs.hyprland.enable {
    NVD_BACKEND = "direct";
    GBM_BACKEND = "nvidia-drm";
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    #VDPAU_DRIVER = "va_gl";
    VDPAU_DRIVER = "nvidia";
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
      open = true; #YOU CAN SET THIS TO FALSE AND IT WILL ALSO BUILD
      nvidiaSettings = true;

      # Apply CachyOS kernel 6.19 patch to NVIDIA latest driver
      package = nvidiaDriverChannel;

      powerManagement.enable = true;

      modesetting.enable = true;
      dynamicBoost.enable = lib.mkForce true;
      };
      graphics = {
        enable = true;
        # Do NOT set `package` here: it defaults to `lib.mkDefault pkgs.mesa`
        # and is the *default driver set*, not the GPU driver. Overriding it
        # with the NVIDIA driver wipes Mesa out of /run/opengl-driver (no
        # libgbm/libGL/libva/DRI), which breaks VA-API and the AMD iGPU.
        # The NVIDIA driver is injected via hardware.graphics.extraPackages
        # by the nixpkgs nvidia module; hardware.nvidia.package above selects it.
        enable32Bit = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
          libva-vdpau-driver
          libvdpau-va-gl
          egl-wayland
        ];
      };
    };    
  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
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
    substituters = ["https://cache.nixos-cuda.org"];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };
}
