---
title: mpd
nav_order: 39
---

# mpd

Includes:
- [Music Player Daemon](https://www.musicpd.org) (Server-side application for playing music)
- [mpc](https://www.musicpd.org/clients/mpc) (A minimalist command line interface to MPD)
- [mpDris2](https://github.com/eonpatapon/mpDris2) (Control MPD like any other application with multimedia keys etc)
- [ncmpcpp](https://rybczak.net/ncmpcpp) (A TUI MPD client)

Works with (Flatpak) GUI Clients like [plattenalbum](https://github.com/SoongNoonien/plattenalbum) and [Cantata](https://github.com/nullobsi/cantata).

# Usage

(Install like any other sysext at the moment)

`mkdir -p ~/.config/mpd`

stock config setup:

`cp /usr/etc/mpd.conf ~/.config/mpd`

[sensible default config](https://github.com/LukeSmithxyz/voidrice/blob/c43f390f07098c42db5efce654b07870951b512a/.config/mpd/mpd.conf) (Pipewire):

`systemctl --user enable --now mpd mpDris2`

Use localhost and port 6600 to connect with the client.

# Why

MPD is in RPMFusion, mpDris2 behaves weirdly/can't autostart in a quadlet/distrobox.

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

install_sysext mpd
```

## Activating the sysext

```
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```

## Updating the sysext

```
sudo /usr/lib/systemd/systemd-sysupdate update --component mpd
sudo systemctl restart systemd-sysext.service
systemd-sysext status
```
