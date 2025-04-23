---
title: incus
nav_order: 21
---

# incus

Work in progress sysext for Incus.

See:
- <https://linuxcontainers.org/incus/docs/main/installing/>
- <https://github.com/ganto/copr-lxc4/wiki/Getting-Started-with-Incus-on-Fedora>
- <https://copr.fedorainfracloud.org/coprs/ganto/lxc4/>

## Versions available

See the [incus versions](https://github.com/travier/fedora-sysexts-exp/releases/tag/incus).

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

install_sysext incus
```

## Activating the sysext

```
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```

## Updating the sysext

```
sudo /usr/lib/systemd/systemd-sysupdate update --component incus
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```
