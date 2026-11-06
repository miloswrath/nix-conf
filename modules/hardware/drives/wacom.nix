{lib, ...}: {
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };

  # Keep tablet support available without running the daemon every login.
  # With a tablet connected: systemctl --user start opentabletdriver.service
  # Check detection with: journalctl --user -u opentabletdriver.service
  systemd.user.services.opentabletdriver.wantedBy = lib.mkForce [];
}
