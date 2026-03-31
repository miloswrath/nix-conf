{ config, pkgs, ... }: {
  boot.kernelParams = [
    "intel_pstate=active"
    "i915.enable_guc=3" # Enable GuC/HuC firmware loading for i915 (primary driver for Meteor Lake iGPU)
    "i915.enable_psr=2" # Panel Self Refresh for power savings
    "i915.enable_fbc=1" # Framebuffer compression
    "i915.fastboot=1" # Skip unnecessary mode sets at boot
    "mem_sleep_default=deep" # Allow deepest sleep states
    "i915.enable_dc=2" # Display power saving
    "i915.enable_rc6=7" # deepest RC6 idle state (aggressive power gating for iGPU)
    "nvme.noacpi=1" # Helps with NVME power consumption
    "intel_pstate.ecpp=115"
    "pcie_aspm=force" # Enable PCIe Active State Power Management
  ];
  # Do NOT blacklist i915 – it's the primary driver for Meteor Lake iGPU; blacklisting causes no GPU detection, leading to Aquamarine backend failure and crash
  # boot.blacklistedKernelModules = [ "i915" ]; # <-- Reverted; causes the core dump

  # Load i915 explicitly if needed (Xe can coexist but isn't required here)
  boot.initrd.kernelModules = [ "i915" ]; # Primary for Meteor Lake; add "xe" only if testing discrete-like features

  # Load the driver
  services.xserver.videoDrivers = [ "modesetting" ];
  services.lact.enable = false;
  services.throttled.enable = false; # Disable; not needed for Intel Ultra 7 (Meteor Lake) – use thermald/TLP instead

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

  # Thermal and Noise Management
  services.thermald.enable = true; # Handles CPU/iGPU thermal zones adaptively for disaggregated Meteor Lake

  # Custom thermald tuning optional: Lower iGPU trip points if overheating (e.g., via /etc/thermald/thermal-conf.xml)
  services.thermald.configFile = pkgs.writeText "thermal-conf.xml" ''
    <?xml version="1.0"?>
    <ThermalConfiguration>
      <Platform>
        <Name>Generic</Name>
        <Preference>QUIET</Preference>
        <ThermalZones>
          <ThermalZone>
            <Type>GPU</Type>
            <TripPoints>
              <TripPoint>
                <SensorType>5</SensorType>
                <Temperature>75000</Temperature>
                <type>Passive</type>
                <CoolingDev>0</CoolingDev>
              </TripPoint>
            </TripPoints>
          </ThermalZone>
        </ThermalZones>
      </Platform>
    </ThermalConfiguration>
  '';


  # Power profiles for easy switching (affects iGPU clocks via i915)
  #  services.power-profiles-daemon.enable = true;

  # System-wide tools
  environment.systemPackages = with pkgs; [
    intel-gpu-tools # intel_gpu_top for iGPU thermal/freq monitoring
  ];

  # Remove the Xe SLPC service – not applicable/relevant for i915-driven iGPU; could interfere with init
  # systemd.services.xe-slpc-power-saving = { ... }; # <-- Reverted
}
