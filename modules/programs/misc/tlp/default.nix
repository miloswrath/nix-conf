{...}: {
  services.tlp = {
    enable = true;
    settings = {
      # More thermal-aware governor
      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";

      # More energy-efficient policy under load
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";  # vs "balance_performance"

      # Hard performance cap: limit turbo bursts
      CPU_MAX_PERF_ON_AC = 77;  # ~64% reduces heat spikes, still responsive
      CPU_MIN_PERF_ON_AC = 0;

      # On battery: already good
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 50;

      # Battery charge thresholds
      START_CHARGE_THRESH_BAT0 = 82;
      STOP_CHARGE_THRESH_BAT0 = 95;
      START_CHARGE_THRESH_BAT1 = 82;
      STOP_CHARGE_THRESH_BAT1 = 95;
    };
  };
}
