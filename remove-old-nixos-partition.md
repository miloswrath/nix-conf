# Remove old NixOS install from `/dev/nvme0n1`

## What's on the disk right now

```
NAME        FSTYPE LABEL UUID                                 MOUNTPOINT   SIZE
nvme0n1                                                                    931.5G
├─nvme0n1p1 vfat         C28C-66CE                            /boot          1G   ← shared EFI System Partition (current install)
├─nvme0n1p2 ext4         51b470cf-1ab5-4d86-bbbf-b5b180d0489b              530.5G  ← OLD install root (unmounted)
├─nvme0n1p3 ext4         29728d6b-670a-4b6b-a80d-7160b365d763                1G    ← empty (unmounted, only lost+found)
└─nvme0n1p4 ext4         ffd96ded-bb1c-4aaa-8499-8139e6094e5d /            399G   ← CURRENT root
```

### Confirmed identity

**Authoritative check: device path, not hostname.** `findmnt -no SOURCE /` reads the live kernel mount table and has consistently returned `/dev/nvme0n1p4` — that's the fact that actually matters and it can't be spoofed by editing a hostname file anywhere. Everything below is corroborating detail, not the load-bearing check.

- **p2**: mounted and inspected — it's an older install of this same machine (`hosts/common.nix` declares `networking.hostName = "zaddys";` for the current config, and p2 originally carried the same name, which is how these two got confused in the first place). Its `/etc/hostname` was manually edited to `zaddy-test` as a marker. **p2 = the old install to remove**, identified by device path `/dev/nvme0n1p2`, independent of any hostname.
- **p3**: mounted and inspected — ext4 filesystem containing only an empty `lost+found`. Never actually populated with a real `/boot` (kernel/initrd/grub.cfg). Nothing to back up here regardless of its original purpose.
- Both are unmounted right now and not referenced anywhere in `/etc/fstab` or this repo (checked — no hits for their UUIDs).
- `hosts/common.nix` has `boot.loader.grub.useOSProber = true;`, which is exactly what makes GRUB scan other partitions and add a menu entry for a foreign OS install — that's almost certainly how the old distro (p2) is showing up in your boot menu.

**Note:** running `hostnamectl set-hostname zaddy-test` without first `chroot`-ing into `/mnt/old-root` changes the *live, currently running* system's hostname, not the mounted partition's — systemd-hostnamed always operates on the live system. That's what happened here: the running system's live hostname is now transiently `zaddy-test` instead of its configured `zaddys`. Harmless (a future `nixos-rebuild switch`/`boot` reasserts `zaddys` from `hosts/common.nix` automatically), but you can fix it immediately with `sudo hostnamectl set-hostname zaddys` if you'd rather not wait. The two partitions were never connected — this was two independent edits (one via `hostnamectl` hitting the live system, one via direct file edit on p2) landing on the same string by chance.

**Before running the deletion commands in this doc, do the final verification pass below** — it re-confirms live, at deletion time, that the running root is `/dev/nvme0n1p4`.

---

## Checklist

- [x] 1. Mount p2/p3 read-only and confirm they're the old install (not something else) — **done**: p2 hostname changed to `zaddys`, p3 confirmed empty
- [ ] 2. Copy off anything you still want from the old install
- [x] 3. Final live re-verification immediately before deleting — **done**: `findmnt -no SOURCE /` → `/dev/nvme0n1p4`, confirmed twice, consistent
- [ ] 4. Get partitioning tools (`parted`/`wipefs`/`efibootmgr` aren't installed on this system)
- [ ] 5. Wipe filesystem signatures on p2/p3
- [ ] 6. Delete the p3 and p2 partition table entries
- [ ] 7. Refresh the kernel's view of the partition table
- [ ] 8. Rebuild NixOS so GRUB regenerates without the os-prober entry
- [ ] 9. Reboot and confirm the old entry is gone from the GRUB menu
- [ ] 10. (Optional, separate task) reclaim the freed 531.5G into your current root

---

## Commands

### 1. Final verification — run immediately before step 4+ and confirm the output matches

These check the *live, running* system at the moment you're about to delete, so a wrong assumption made earlier can't carry through:

```bash
# 1. current running root must be p4 - this is the authoritative check
findmnt -no SOURCE /
# expect: /dev/nvme0n1p4

# 2. mount p2 read-only and confirm it's still the old install's marker
#    (do NOT run `hostnamectl set-hostname` here - it affects the LIVE system,
#    not the mounted partition; only chroot would scope it correctly)
sudo mkdir -p /mnt/old-root /mnt/old-boot
sudo mount -o ro /dev/nvme0n1p2 /mnt/old-root
cat /mnt/old-root/etc/hostname
# expect: zaddy-test

# 3. p3 - reconfirm it's still just the empty filesystem
sudo mount -o ro /dev/nvme0n1p3 /mnt/old-boot
ls -la /mnt/old-boot
# expect: only lost+found/, empty

# 4. check the shared ESP for extra vendor directories from other installs (needs sudo, dmask=0077)
sudo ls -la /boot/EFI/

sudo umount /mnt/old-root /mnt/old-boot
```

Send me the output and I'll confirm before you move on to deletion. **Step 1 (`findmnt`) is the only check that actually gates safety** — if it doesn't print `/dev/nvme0n1p4`, stop immediately, the disk state has changed and this document no longer applies as-is. Steps 2–4 are corroborating detail only.

### 2. Back up anything you want (optional)

```bash
sudo rsync -avh --progress /mnt/old-root/home/<olduser>/ /home/zak/old-nixos-backup/
```

Then unmount:

```bash
sudo umount /mnt/old-root /mnt/old-boot
```

### 3. Re-confirm nothing references these partitions

```bash
grep -rn "51b470cf-1ab5-4d86-bbbf-b5b180d0489b\|29728d6b-670a-4b6b-a80d-7160b365d763" /etc/nixos/ /home/zak/NixOS/
```

Should print nothing.

### 4. Get tools (not currently installed on this system)

```bash
nix-shell -p parted gptfdisk efibootmgr
```

Run the rest of the commands inside that shell (or prefix each with `nix-shell -p parted gptfdisk efibootmgr --run '...'`).

### 5. Wipe filesystem signatures

Do this **before** removing the partition entries, while the device nodes still exist:

```bash
sudo wipefs -a /dev/nvme0n1p3
sudo wipefs -a /dev/nvme0n1p2
```

### 6. Delete the partition entries

Confirm the layout one more time, then delete the higher-numbered partition first:

```bash
sudo parted /dev/nvme0n1 print
sudo parted /dev/nvme0n1 rm 3
sudo parted /dev/nvme0n1 rm 2
sudo parted /dev/nvme0n1 print
```

### 7. Refresh the kernel's partition table view

```bash
sudo partprobe /dev/nvme0n1
lsblk -f /dev/nvme0n1
```

`nvme0n1p2` and `nvme0n1p3` should no longer appear.

### 8. Rebuild so GRUB drops the os-prober entry

`useOSProber` re-scans the disk live during activation, so a rebuild regenerates `grub.cfg` without the stale entry:

```bash
sudo nixos-rebuild boot
```

### 9. Reboot and verify

```bash
sudo reboot
```

Confirm the GRUB menu no longer lists the old NixOS install.

---

## 10. (Optional/advanced) Reclaim the freed space

p2+p3 sit **before** your current root (`p4`) on the disk, not after. Growing `p4` into that space means moving its start sector backward, not just extending its end — `parted`/`resize2fs` can't do that live on a mounted, booted root filesystem. To actually reclaim the ~531.5G you'd need to:

1. Boot from a live USB (GParted Live or similar) so `p4` isn't mounted/in-use.
2. Use GParted to move+grow `p4` leftward into the freed space.
3. This physically shifts ~399G of data and can take a long time — **back up first**, and only do it if you actually need the space. Leaving it as unallocated free space is completely safe and reversible (you can partition it later for anything).

If you just want the old distro gone and out of your boot menu, steps 1–9 are sufficient — stop there.
