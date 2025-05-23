#!/usr/bin/bash

set -eu

if [[ " $* " =~ " -v " ]]
then
  set -x
fi

compose_cmd=(podman compose)
if ! "${compose_cmd[@]}" >/dev/null 2>/dev/null
then
  compose_cmd=(docker compose)
  if ! "${compose_cmd[@]}" > /dev/null 2>/dev/null
  then
    echo "Failed to find podman or docker compose! Please make sure either is installed."
    exit 1
  fi
fi

read -rp 'Enter a server name: ' SERVER_NAME
read -rp 'Enter a server password: ' SERVER_PASSWORD
read -rp 'Enter a admin password: ' ADMIN_PASSWORD

mkdir -p mordhau
cd mordhau
wget https://raw.githubusercontent.com/theCalcaholic/mordhau-server/refs/heads/main/compose.yml -O ./compose.yml
mkdir -p game
chown 1000:1000 game

echo "Starting service to generate game files (max wait time: 5min)..."
"${compose_cmd[@]}" up -d

for i in {1..300}
do
  if [[ -f ./game/cfg/Game.ini ]]
  then
    break
  else
    sleep 1
  fi
done

if ! [[ -f ./game/cfg/Game.ini ]]
then
  "${compose_cmd[@]}" logs
  echo "Game config files missing after 2 minutes. Somethings seems to have gone wrong with the server."
  "${compose_cmd[@]}" down
  exit 1
fi

"${compose_cmd[@]}" down

sed -i \
  -e "/ServerName=/s/=.*/=${SERVER_NAME?}/" \
  -e "/ServerPassword=/s/=.*/=${SERVER_PASSWORD?}/" \
  -e "/AdminPassword=/s/=.*/=${ADMIN_PASSWORD?}/" \
  ./game/cfg/Game.ini

"${compose_cmd[@]}" up -d
"${compose_cmd[@]}" logs -f

