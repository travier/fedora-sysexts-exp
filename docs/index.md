---
nav_order: 1
---

# systemd system extensions for Fedora image based systems

**NOTE: This is still experimental, use at your own risk.**

This projects makes sysexts available for Fedora CoreOS, Atomic Desktops, IoT,
or other Bootable Container systems (and classic ostree/rpm-ostree systems).

## What are sysexts?

See the
[Extension Images](https://uapi-group.org/specifications/specs/extension_image/)
specification from the UAPI group.

## Available sysexts

You can find all the available sysexts in the list on the side of this page.

## Installing and updating using `systemd-sysupdate`

You can currently install and update those sysexts using `systemd-sysupdate`.
See the individual pages for instructions.

You can also directly download the sysexts images as files in a Butane config
for example.

## Updating all installed sysexst

Example to update all sysexts on a system:

```
for c in $(/usr/lib/systemd/systemd-sysupdate components --json=short | jq --raw-output '.components[]'); do
    sudo /usr/lib/systemd/systemd-sysupdate update --component "${c}"
done
```

## Know issues

### Use `systemctl restart systemd-sysext.service` to refresh sysexts

Until systemd v257 is released and lands in Fedora, make sure to use `systemctl
restart systemd-sysext.service` instead of `systemd-sysext merge`.
`systemd-sysext unmerge` is safe to use.

See:
- <https://github.com/coreos/fedora-coreos-tracker/issues/1744>
- <https://github.com/systemd/systemd/issues/34387>
- <https://github.com/systemd/systemd/pull/34414>
- <https://github.com/systemd/systemd/pull/35132>

## Current limitation of systemd-sysupdate

While installing and updating via `systemd-sysupdate` works, this also has a
few limitations (thus the experimental status): The sysexts are enabled
"statically" for all deplpoyments and if you rebase between major Fedora
versions, the sysexts will not match the Fedora release and will not be loaded
until you update again using `systemd-sysupdate`.

## Building, contributing and license

See the project [README](https://github.com/travier/fedora-sysexts-exp).
