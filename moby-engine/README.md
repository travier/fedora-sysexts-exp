# moby-engine

moby-engine (Docker) from the Fedora repos.

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
