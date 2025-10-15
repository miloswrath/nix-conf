{
  config,
  pkgs,
  ...
}: {
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
  };

  boot.kernelParams = [
    "intel_pstate=active"
    "i915.enable_guc=3" # Enable GuC/HuC firmware loading
    "i915.enable_psr=2" # Panel Self Refresh for power savings
    "i915.enable_fbc=1" # Framebuffer compression
    "i915.fastboot=1" # Skip unnecessary mode sets at boot
    "mem_sleep_default=deep" # Allow deepest sleep states
    "i915.enable_dc=2" # Display power saving
    "i915.enable_rc6=7" # deepest RC6 idle state
    "nvme.noacpi=1" # Helps with NVME power consumption
    "intel_pstate.ecpp=115"
    "xe.forceprobe=*"
  ];

  # Load the driver
  services.xserver.videoDrivers = ["modesetting"];
  services.lact.enable = false;
  hardware.enableAllFirmware = true;

  hardware.cpu.intel.updateMicrocode = true; # get all microcode fixes
  boot.initrd.kernelModules = ["xe"]; # newer Meteor Lake driver
  # OpenGL
  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      vpl-gpu-rt
    ];
  };

  # Thermal and Noise Management
  services.thermald.enable = true;
  services.throttled.enable = true;
}
