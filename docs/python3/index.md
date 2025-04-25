---
title: python3
nav_order: 43
---

# python3

Only core Python 3 packages. For Fedora CoreOS only.

## Versions available

See the [python3 versions](https://github.com/travier/fedora-sysexts-exp/releases/tag/python3).

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
install_sysext python3
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
sudo /usr/lib/systemd/systemd-sysupdate update --component python3
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
