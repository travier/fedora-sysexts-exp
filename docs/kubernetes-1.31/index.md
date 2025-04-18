---
title: kubernetes-1.31
nav_order: 28
---

# kubernetes-1.31

Kubernetes packages and direct dependencies only. Needs to be combined with a
container runtime such as `containerd`, either from Fedora's packages or the
`docker-ce` sysext.

For Kubernetes and CRI-O in a single system extension, see `kubernetes-cri-o-<version>` ones.
For CRI-O only, see the `cri-o-<version>` ones.

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

install_sysext kubernetes-1.31
```

## Activating the sysext

```
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```

## Updating the sysext

```
sudo /usr/lib/systemd/systemd-sysupdate update --component kubernetes-1.31
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```
