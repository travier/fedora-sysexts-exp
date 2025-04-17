---
title: kubernetes-cri-o-1.32 sysext
nav_order: 10
---

# kubernetes-cri-o-1.32

## Compatible images

```
quay.io/fedora/fedora-coreos:stable x86_64,aarch64
quay.io/fedora/fedora-coreos:next x86_64,aarch64
```

## Versions available

TODO

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
  URL="https://extensions.fcos.fr/extensions"
  SYSEXT="${1}"
  sudo install -d -m 0755 -o 0 -g 0 /etc/sysupdate.${SYSEXT}.d
  sudo restorecon -RFv /etc/sysupdate.${SYSEXT}.d
  curl --silent --fail --location "${URL}/${SYSEXT}.conf" | sudo tee "/etc/sysupdate.${SYSEXT}.d/${SYSEXT}.conf"
  sudo /usr/lib/systemd/systemd-sysupdate components
  sudo /usr/lib/systemd/systemd-sysupdate update --component "${SYSEXT}"
}

install_sysext kubernetes-cri-o-1.32
```

## Activating the sysext

```
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```

## Updating the sysext

```
SYSEXT="kubernetes-cri-o-1.32"
sudo /usr/lib/systemd/systemd-sysupdate update --component ${SYSEXT}
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```
