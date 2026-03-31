{...}: {
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power"; # Conservative for thermal headroom

      # iGPU power limits (i915-specific; adjust for your Ultra 7 155H/165H max ~1.5GHz)
      INTEL_GPU_MIN_FREQ_ON_AC = 500;
      INTEL_GPU_MAX_FREQ_ON_AC = 1200; # Cap for thermal (vs. 1500 stock)
      INTEL_GPU_MIN_FREQ_ON_BAT = 300;
      INTEL_GPU_MAX_FREQ_ON_BAT = 900; # Aggressive downclock on battery

      # PCIe ASPM
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersave";

      # Runtime PM for iGPU
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      # Sound power saving (if applicable)
      SOUND_POWER_SAVE_ON_BAT = 1;

      SOUND_POWER_SAVE = 1;
    };
  };
}
