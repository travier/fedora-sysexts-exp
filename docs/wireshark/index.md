---
title: wireshark
nav_order: 58
---

# wireshark

## How to use

- Install the system extension
- Add users to the `tcpdump` group:
  ```
  $ grep -E '^tcpdump:' /usr/lib/group | sudo tee -a /etc/group
  $ sudo usermod --append --groups=tcpdump $USER
  ```

## Why not use the Flatpak?

It should currently be possible to use the Wireshark Flatpak and connect to the
local system via SSH to a rootful container that has tcpdump installed.

See: https://discussion.fedoraproject.org/t/silverblue-wireshark-does-not-see-network-interfaces/88916/11

This requires some manual setup so using this sysext should be easier.

## Why not use layering?

See: <https://github.com/fedora-silverblue/issue-tracker/issues/50>

## Versions available

See the [wireshark versions](https://github.com/travier/fedora-sysexts-exp/releases/tag/wireshark).

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

install_sysext wireshark
```

## Activating the sysext

```
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```

## Updating the sysext

```
sudo /usr/lib/systemd/systemd-sysupdate update --component wireshark
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```
