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
  URL="%%EXTENSIONSURL%%"
  SYSEXT="${1}"
  sudo install -d -m 0755 -o 0 -g 0 /etc/sysupdate.${SYSEXT}.d
  sudo restorecon -RFv /etc/sysupdate.${SYSEXT}.d
  curl --silent --fail --location "${URL}/${SYSEXT}.conf" | sudo tee "/etc/sysupdate.${SYSEXT}.d/${SYSEXT}.conf"
  sudo /usr/lib/systemd/systemd-sysupdate components
  sudo /usr/lib/systemd/systemd-sysupdate update --component "${SYSEXT}"
}

install_sysext %%SYSEXT%%
```

## Activating the sysext

```
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```

## Updating the sysext

```
SYSEXT="%%SYSEXT%%"
sudo /usr/lib/systemd/systemd-sysupdate update --component ${SYSEXT}
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```
