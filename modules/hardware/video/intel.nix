{
  config,
  lib,
  pkgs,
  defaultPowerProfile,
  ...
}: {
  boot.kernelParams = [
    "intel_pstate=active"
    "i915.enable_guc=3" # Enable GuC/HuC firmware loading for i915 (primary driver for Meteor Lake iGPU)
    "i915.enable_psr=2" # Panel Self Refresh for power savings
    "i915.enable_fbc=1" # Framebuffer compression
    "mem_sleep_default=deep" # Allow deepest sleep states
    "i915.enable_dc=2" # Display power saving
    "nvme.noacpi=1" # Helps with NVME power consumption
    "pcie_aspm=force" # Enable PCIe Active State Power Management
  ];
  # Do NOT blacklist i915 – it's the primary driver for Meteor Lake iGPU; blacklisting causes no GPU detection, leading to Aquamarine backend failure and crash
  # boot.blacklistedKernelModules = [ "i915" ]; # <-- Reverted; causes the core dump

  # Load i915 explicitly if needed (Xe can coexist but isn't required here)
  boot.initrd.kernelModules = ["i915"]; # Primary for Meteor Lake; add "xe" only if testing discrete-like features

  # Load the driver
  services.xserver.videoDrivers = ["modesetting"];
  services.lact.enable = false;
  services.throttled.enable = false;

  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true; # get all microcode fixes

  # OpenGL and media acceleration (uses i915)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API for i915/Xe
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
      vpl-gpu-rt
      intel-gpu-tools # For monitoring with intel_gpu_top
    ];
  };

  # With no custom XML, NixOS runs thermald --adaptive using firmware DPTF tables.
  services.thermald.enable = true;

  # Use one owner for CPU energy/performance hints; profiles remain selectable
  # through powerprofilesctl or the desktop's power menu.
  services.power-profiles-daemon.enable = true;
  systemd.services.power-profiles-daemon.postStart = ''
    ${lib.getExe' config.services.power-profiles-daemon.package "powerprofilesctl"} set ${lib.escapeShellArg defaultPowerProfile}
  '';

  # Reapply the configured default whenever the daemon starts (including boot).
  # Framework/Meteor Lake verification after nixos-rebuild test:
  # powerprofilesctl get; check cpu*/cpufreq/energy_performance_preference;
  # compare sensors + turbostat during the same playback/call workload.
  # Thermal improvement depends on firmware support and the physical cooling.

  # System-wide tools
  environment.systemPackages = with pkgs; [
    intel-gpu-tools # intel_gpu_top for iGPU thermal/freq monitoring
  ];

  # Remove the Xe SLPC service – not applicable/relevant for i915-driven iGPU; could interfere with init
  # systemd.services.xe-slpc-power-saving = { ... }; # <-- Reverted
}
