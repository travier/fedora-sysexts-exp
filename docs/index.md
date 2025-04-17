---
nav_order: 1
---

# systemd system extensions for Fedora image based systems

**NOTE: This is still experimental, use at your own risk.**

This projects makes sysexts available for Fedora CoreOS, Atomic Desktops, IoT,
or other Bootable Container systems (and classic ostree/rpm-ostree systems).

## What are sysexts?

TODO

## Available sysexts

TODO

## Installing and updating using systemd-sysupdate

In the meantime, you can use systemd-sysupdate to manually install and update
them:

```
$ sudo install -d -m 0755 -o 0 -g 0 /var/lib/extensions /var/lib/extensions.d
$ sudo restorecon -RFv /var/lib/extensions /var/lib/extensions.d
```

```
$ URL="https://extensions.fcos.fr/extensions/"
$ SYSEXT="htop"
$ sudo install -d -m 0755 -o 0 -g 0 /etc/sysupdate.${SYSEXT}.d
$ sudo restorecon -RFv /etc/sysupdate.${SYSEXT}.d
$ curl --silent --fail --location "${URL}/${SYSEXT}.conf" | sudo tee "/etc/sysupdate.${SYSEXT}.d/${SYSEXT}.conf"
$ sudo /usr/lib/systemd/systemd-sysupdate components
$ sudo /usr/lib/systemd/systemd-sysupdate update --component "${SYSEXT}"
$ sudo systemctl restart systemd-sysext.service
$ systemd-sysext status
```

Then any further updates can be done with:

```
$ SYSEXT="htop"
$ sudo /usr/lib/systemd/systemd-sysupdate update --component ${SYSEXT}
$ sudo systemctl restart systemd-sysext.service
$ systemd-sysext status
```

TODO

## Know issues

Until systemd v257 is released and lands in Fedora, make sure to use `systemctl
restart systemd-sysext.service` instead of `systemd-sysext merge`.
`systemd-sysext unmerge` is safe to use.

See:
- https://github.com/coreos/fedora-coreos-tracker/issues/1744
- https://github.com/systemd/systemd/issues/34387
- https://github.com/systemd/systemd/pull/34414
- https://github.com/systemd/systemd/pull/35132

## Building, contributing and license

See the project [README](https://github.com/travier/fedora-sysexts-exp).
