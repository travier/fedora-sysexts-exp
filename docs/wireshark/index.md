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
install_sysext wireshark
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
sudo /usr/lib/systemd/systemd-sysupdate update --component wireshark
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
