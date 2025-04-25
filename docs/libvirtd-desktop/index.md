---
title: libvirtd-desktop
nav_order: 37
---

# libvirtd-desktop

`libvirtd`, `qemu`, `swtpm`, `virt-install` and `guestfs-tools` for desktop
usage.

See the [Virtual Machine Manager Flatpak](https://flathub.org/apps/org.virt_manager.virt-manager).

## How to use

- Install the sysext
- Create the `qemu` user:
  ```
  $ sudo systemd-sysusers /usr/lib/sysusers.d/libvirt-qemu.conf
  ```
- Copy the some default config:
  ```
  $ sudo cp -a /usr/etc/mdevctl.d /etc/
  ```
- Optional: Copy the default libvirtd config (note that it won't be updated automatically):
  ```
  $ sudo cp -a /usr/etc/libvirt /etc/
  ```
- Optional: Setup auth via polkit (example):
  ```
  $ sudo cat /etc/polkit-1/rules.d/50-libvirt.rules
  polkit.addRule(function(action, subject) {
      if (action.id == "org.libvirt.unix.manage" &&
          subject.isInGroup("wheel")) {
              return polkit.Result.YES;
      }
  });
  ```
- Restart libvirtd (via virtqemud, virtnetworkd & virtstoraged):
  ```
  $ sudo systemctl restart virtqemud.socket virtnetworkd.socket virtstoraged.socket
  ```

## Versions available

See the [libvirtd-desktop versions](https://github.com/travier/fedora-sysexts-exp/releases/tag/libvirtd-desktop).

## Usage instructions

<details markdown="block">
<summary>First time setup</summary>
Run those commands if you have not yet installed any sysext on your system:

```
sudo install -d -m 0755 -o 0 -g 0 /var/lib/extensions /var/lib/extensions.d
sudo restorecon -RFv /var/lib/extensions /var/lib/extensions.d
```
</details>

<details markdown="block">
<summary>Installation</summary>
Define a helper function:

```
install_sysext() {
  SYSEXT="${1}"
  URL="https://extensions.fcos.fr/extensions"
  sudo install -d -m 0755 -o 0 -g 0 /etc/sysupdate.${SYSEXT}.d
  sudo restorecon -RFv /etc/sysupdate.${SYSEXT}.d
  curl --silent --fail --location "${URL}/${SYSEXT}.conf" \
    | sudo tee "/etc/sysupdate.${SYSEXT}.d/${SYSEXT}.conf"
  sudo /usr/lib/systemd/systemd-sysupdate update --component "${SYSEXT}"
}
```

Install the sysext:

```
install_sysext libvirtd-desktop
```
</details>

<details markdown="block">
<summary>Merging</summary>
Note that this will merge all installed sysexts unconditionally:

```
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```
</details>

<details markdown="block">
<summary>Updates</summary>
Update this sysext using:

```
sudo /usr/lib/systemd/systemd-sysupdate update --component libvirtd-desktop
```

If you want to use the new version immediately, make sure to refresh the merged
sysexts:

```
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```

To update all sysexts on a system:

```
for c in $(/usr/lib/systemd/systemd-sysupdate components --json=short | jq --raw-output '.components[]'); do
    sudo /usr/lib/systemd/systemd-sysupdate update --component "${c}"
done
```
</details>
