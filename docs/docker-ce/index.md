---
title: docker-ce
nav_order: 11
---

# docker-ce

Docker Engine from [community repos](https://docs.docker.com/engine/install/fedora/).

## How to use

- Install the sysext
- Create the `docker` group:
  ```
  $ sudo groupadd --system docker
  ```
- Restart the socket:
  ```
  $ sudo systemctl enable --now docker.socket
  ```

## Versions available

See the [docker-ce versions](https://github.com/travier/fedora-sysexts-exp/releases/tag/docker-ce).

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

install_sysext docker-ce
```

## Activating the sysext

```
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```

## Updating the sysext

```
sudo /usr/lib/systemd/systemd-sysupdate update --component docker-ce
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```
