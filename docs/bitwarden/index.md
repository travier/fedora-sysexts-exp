---
title: bitwarden
nav_order: 5
---

# bitwarden

The [Bitwarden](https://bitwarden.com/) password manager.

## Differences from the Flatpak version

While both the packaged version and the Flatpak version are equal in core
functionality, some features (e.g.: biometrics autosetup and the ssh-agent sock
present at `$HOME/.bitwarden-ssh-agent.sock` ) are still only available in the
non-sandboxed version of the app.

## Versions available

See the [bitwarden versions](https://github.com/travier/fedora-sysexts-exp/releases/tag/bitwarden).

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
install_sysext bitwarden
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
sudo /usr/lib/systemd/systemd-sysupdate update --component bitwarden
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
