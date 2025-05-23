# Mordhau Server Setup script

## Requirements

1. Have a publicly reachable IP address
2. Have either podman + podman-compose or docker + docker-compose installed

## Usage

Run the following command from a bash session, which will ask you for a server name, server password and admin password and setup your mordhau server in a subdirectory called `mordhau`:

```bash
bash <(wget https://raw.githubusercontent.com/theCalcaholic/mordhau-server/refs/heads/main/setup.sh -O -)
```

