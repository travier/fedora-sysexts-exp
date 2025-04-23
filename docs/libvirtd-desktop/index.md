---
title: libvirtd-desktop
nav_order: 34
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

## First time setup

Run those commands if you have not yet installed any sysext on your system:

```
sudo install -d -m 0755 -o 0 -g 0 /var/lib/extensions /var/lib/extensions.d
sudo restorecon -RFv /var/lib/extensions /var/lib/extensions.d
```

## Installing the sysext

Define a helper function and then install the sysext:

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

install_sysext libvirtd-desktop
```

## Activating the sysext

```
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```

## Updating the sysext

```
sudo /usr/lib/systemd/systemd-sysupdate update --component libvirtd-desktop
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```
