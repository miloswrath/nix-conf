{pkgs, ...}: {
  imports = [./hooks.nix];

  # virt-manager
  programs.virt-manager.enable = true;

  # Guest agents belong inside virtual machines, not on this physical host.
  services.qemuGuest.enable = false;
  services.spice-vdagentd.enable = false;
  services.spice-webdavd.enable = false;

  # packages
  environment.systemPackages = with pkgs; [
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
  ];

  # virtualisation
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm; # TODO: Test
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
