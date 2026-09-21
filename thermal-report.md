# Framework 13 thermal investigation

2026-09-08 · Core Ultra 7 155H · NixOS 26.11 · running kernel 7.1.7

**Assessment:** The hot workload doubles measured package power, eliminates reported package idle-state residency, and produces thermal-throttle counter increments concentrated on two P-cores. **CPU/package activity is the main measured heat contributor; GPU saturation is not supported. Brave uses the hardware video engine.** Sustained maximum-frequency boosting is not supported. Cooling effectiveness remains unresolved because the captures contain no temperatures. Software fixes below are built but not activated; firmware is unchanged.

## Local evidence

User-provided [idle capture](/tmp/thermal-idle.txt) and [hot capture](/tmp/thermal-hot.txt): 30 two-second intervals each. Values below are averages unless marked otherwise.

| Measurement | Idle | Hot workload |
|---|---:|---:|
| CPU busy | 0.60% | **2.39%** (maximum 7.30%) |
| Package power | **5.71 W** | **11.57 W** (maximum 23.16 W) |
| CPU core-domain power | 1.77 W | **6.47 W** |
| Graphics-domain power | 0.07 W | **0.46 W** |
| Reported package C2/C3/C6/C8/C10 residency, combined | 9.78% | **0% throughout** |
| Average of interval busy-frequency summaries | 2.13 GHz | 2.31 GHz |
| Intervals with nonzero `CoreThr` | 0/30 | **14/30** |

Core IDs **8 and 12** account for 317 of 320 summed per-core throttle-counter increments. These are counter increments, not seconds throttled. Their busiest logical threads average 12.0% and 9.3% utilization: concentrated activity, but neither is continuously saturated. [Counter implementation](https://raw.githubusercontent.com/torvalds/linux/master/tools/power/x86/turbostat/turbostat.c)

The [GPU capture](/tmp/thermal-gpu.json) contains 51 samples (~51 seconds); excluding its initial 16.5-ms sample, graphics power averages **0.50 W**, package power **12.10 W** (maximum 27.96 W), render activity **6.08%**, and video activity **2.39%**. Brave has substantial video-engine activity; Discord has intermittent activity. Hyprland accounts for most measured rendering. Engine counters cannot identify the specific stream, codec, or encode/decode direction; graphics-domain watts are not a complete accounting of every media/display component.

**Measurement limits:** Neither turbostat file includes `CoreTmp`/`PkgTmp`; the hot file warns `Guessing tjMax 100 C`. Therefore these captures do not verify >85°C or correlate temperature/fan speed with watts. Earlier, separate `sensors` measurements were 62–73°C. Reported `SysWatt` rises 21.75→36.39 W but is not CPU heat or a wall-meter measurement. Charging status during the new tests is unconfirmed. Raw files are in temporary storage.

Earlier system checks: EPP `balance_performance`, turbo enabled, 30/60 W package limits; thermald running, no power-profile manager; [scx_lavd autopilot](hosts/common.nix#L111); i915 firmware successfully loaded; Brave Wayland acceleration flags present; display 2880×1920 at 120 Hz/1.25 scale.

## Implemented fixes and remaining comparisons

1. **Power-saving policy implemented.** Core power explains ~4.70 W of the 5.86 W package increase. Enabled power-profiles-daemon with [central default](flake.nix#L64) `power-saver`, reapplied at daemon startup/boot. This favors efficiency and may reduce peak performance. `powerprofilesctl set balanced` changes the running profile. No competing TLP/auto-cpufreq service is enabled. Profile selection controls energy/performance hints; verify the actual EPP after activation. [Kernel documentation](https://cdn.kernel.org/doc/html/latest/admin-guide/pm/intel_pstate.html)

2. **Thermal configuration repaired.** Removed the XML with invalid `<CoolingDev>` and undefined sensor `5`; the [Intel module](modules/hardware/video/intel.nix#L45) now uses NixOS's default `thermald --adaptive`. Removed ignored `i915.fastboot`/`i915.enable_rc6` and undocumented `intel_pstate.ecpp=115`. Kernel-parameter removal takes effect after reboot. [Thermald schema](https://raw.githubusercontent.com/intel/thermal_daemon/master/man/thermal-conf.xml.5)

3. **Complete acceleration failure is now unlikely.** Confirm the specific player's decoder in `brave://media-internals`; inspect call encoding separately. Hardware-engine activity does not exclude partial software fallback, but adding more acceleration flags is no longer the first recommendation. [Chromium verification guide](https://chromium.googlesource.com/chromium/src/+/refs/heads/main/docs/gpu/vaapi.md)

4. **Remaining comparisons:** 60 Hz and the stock scheduler, individually; neither is a proven fault. Zero package sleep under calls does not itself prove a driver bug. The [GPU temperature script](modules/desktop/hyprland/scripts/gpuinfo.sh#L26) can label CPU temperature as GPU temperature.

**Validation:** `nix fmt`, `nix flake check`, and the full Default system build passed. Evaluated units confirm adaptive thermald, power-saver startup, and no conflicting power managers. `nixos-rebuild test` could not run because sudo requires a password. Activate and check:

```sh
sudo nixos-rebuild test --flake .#Default
systemctl status thermald power-profiles-daemon --no-pager
powerprofilesctl get
cat /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
```

Repeat temperature/power measurements. If satisfactory, `sudo nixos-rebuild switch --flake .#Default`, then reboot to apply the kernel-parameter cleanup.

## Known model issues and firmware

Firsthand 155H reports describe similar video/Zoom heating on Windows and Linux; one hot-idle case resolved with mainboard replacement. They do not prove this machine has a defect. [Video reports](https://community.frame.work/t/fw13-intel-ultra-7-155h-p-core-overheating-at-low-usage-when-watching-video/72425), [board replacement](https://community.frame.work/t/idle-temperature/61684)

**Firmware update:** installed BIOS is **03.04**. Correcting the earlier report: the latest stable release is **3.07**, including a Linux GPU-hang fix, not a promised thermal fix. fwupd locally confirms 3.07 on stable `lvfs` for this device. Your 03.04 meets the minimum upgrade requirement. Keep the charger attached and allow update/reboot to finish uninterrupted. [Framework 3.07 instructions](https://resources.frame.work/downloads/laptop-13/intel-core-ultra-series-1/3.07/)

```sh
sudo fwupdmgr refresh --force
fwupdmgr get-updates
sudo fwupdmgr update e40df3702af4b9ead7a46fd24800583e0ddd5d31
# After the update/reboot:
cat /sys/class/dmi/id/bios_version
```

The device ID selects this machine's System Firmware. Framework advises discharging to 95% and reconnecting AC if updating at 100% fails. Its 3.07 instructions also call for loading BIOS defaults (F2 → Setup Utility → F9 → F10); record custom settings first and restore boot/Secure Boot settings needed by this NixOS installation. If LVFS fails, use the model-specific EFI ZIP and Framework's [Linux/EFI guide](https://knowledgebase.frame.work/updating-bios-on-linux-Hk4pROTn).

**Next diagnostic:** capture `sensors` temperatures/fan RPM alongside turbostat during playback alone and playback plus call, then repeat with a power-saving policy. Record charger/battery status. Throttling at these moderate average watts makes cooling/contact worth investigating if sustained high temperatures persist with adequate fan speed; short power spikes and missing temperature data currently prevent that diagnosis.
