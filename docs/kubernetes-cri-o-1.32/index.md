---
title: kubernetes-cri-o-1.32
nav_order: 33
---

# kubernetes-cri-o-1.32

Kubernetes and CRI-O packages in a single system extension.

For Kubernetes only, see the `kubernetes-<version>` ones.
For cri-o only, see the `cri-o-<version>` ones.

## Versions available

See the [kubernetes-cri-o-1.32 versions](https://github.com/travier/fedora-sysexts-exp/releases/tag/kubernetes-cri-o-1.32).

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

install_sysext kubernetes-cri-o-1.32
```

## Activating the sysext

```
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```

## Updating the sysext

```
sudo /usr/lib/systemd/systemd-sysupdate update --component kubernetes-cri-o-1.32
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```
