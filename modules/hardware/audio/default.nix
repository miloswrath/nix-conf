{pkgs, ...}: {
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        # Increase from 32 → 128 (or try 256 if needed)
        "default.clock.quantum" = 256;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 256;
        # Optional: prevent rate switching
        #"default.clock.allowed-rates" = [ 48000 ];
      };
    };
    wireplumber = {
      enable = true;

      configPackages = [
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/11-bluetooth-policy.conf" ''
          bluetooth.autoswitch-to-headset-profile = false
        '')
        # SIMGOT EW300 DSP is a full-speed (USB 1.1) ADAPTIVE-mode USB Audio Class
        # dongle with almost no onboard buffering and no real hw pointer register.
        # The global 92-low-latency 256-sample graph quantum (set above) starves
        # it under scheduling jitter (buzz/crackle), and PipeWire's default
        # timer-based mmap position estimation drifts against this device's
        # jittery reported pointer, which the clock-drift compensator "corrects"
        # by continuously speeding up/slowing down playback (audible pitch
        # bending on long clips). Give it a bigger ALSA-side period/headroom and
        # force plain interrupt-driven IO (disable mmap/batch) instead of
        # touching the global low-latency quantum.
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/51-simgot-ew300-alsa.conf" ''
          monitor.alsa.rules = [
            {
              matches = [
                { device.name = "alsa_card.usb-LE_XIAN_SIMGOT_EW300_DSP_2024-07-03-0000-0000-0000-00" }
              ]
              actions = {
                update-props = {
                  api.alsa.period-size   = 1024
                  api.alsa.headroom      = 8192
                  api.alsa.disable-mmap  = true
                  api.alsa.disable-batch = true
                }
              }
            }
          ]
        '')
      ];
    };
  };
}
