<div align="center">

<img src="https://stationeers-wiki.com/resources/assets/stationeers-wiki.png" align="center" width="144px" height="144px"/>

## Stationeers Dedicated Server using Docker

_Run a Stationeers dedicated server in a single Docker container._

</div>

<div align="center">

![GitHub Repo stars](https://img.shields.io/github/stars/1Solon/stationeers-dedicated-server-docker?style=for-the-badge)
![GitHub forks](https://img.shields.io/github/forks/1Solon/stationeers-dedicated-server-docker?style=for-the-badge)

</div>

## Requirements

- Docker Desktop or compatible runtime with Compose
- Enough disk space for game files and saves (the `./data` folder mounted into the container)

Docs: [https://docs.docker.com/compose/](https://docs.docker.com/compose/)

## Quick start

1. Copy `.env.example` to `.env` and tweak values if needed
2. Build and start

```ps
docker compose up -d --build
```

You're good when you see lines like:

```ps
stationeers-1  | Version : 0.2.x
stationeers-1  | Loading settings: /stationeers/gameData/settings.xml
stationeers-1  | loaded 46 systems successfully
```

## Configuration

Server options are environment variables, read by `data/runstationeers-linux.sh`.

- Edit `.env` to change settings (port, save name/world, visibility, password, etc.)
- The compose file bind-mounts `./data` to `/stationeers` to persist downloads, saves, and logs.
- Default game port is `27016` (both TCP and UDP). Override with `GAME_PORT` in `.env`.

Key variables in `.env`:

- `SERVER_NAME`, `SAVE_NAME`, `WORLD_TYPE`, `DIFFICULTY`
- `SERVER_VISIBLE`, `START_LOCAL_HOST`, `UPNP_ENABLED`, `SERVER_MAX_PLAYERS`
- `SERVER_PASSWORD`, `SERVER_AUTH_SECRET` (optional)
- `GAME_PORT` (host/exposed port)
- `AUTO_SAVE`, `SAVE_INTERVAL`, `LOCAL_IP_ADDRESS`
- `LOG_TO_STDOUT` (compose default `false` so the healthcheck can read `/stationeers/gameData/log.txt`; set `true` to log to stdout and consider disabling or changing the healthcheck)

Advanced users can also adjust `DATA_DIR`, `EXECUTABLE`, `SETTINGS_PATH`, `SAVE_PATH` via env.

## Updates

By default, the container runs SteamCMD on startup to install/update the dedicated server into the mounted `/stationeers/gameServer` folder. To disable, set `AUTO_UPDATE=false` in `.env`.

## Healthcheck

The `stationeers` service is considered healthy when it finds the "loaded .* systems successfully" line in the file log. If you enable `LOG_TO_STDOUT=true`, either disable the healthcheck or change it to something like a port check:

```yaml
healthcheck:
  test: ["CMD-SHELL", "ss -lntu | grep -q ':27016' || exit 1"]
  interval: 30s
  timeout: 5s
  retries: 10
  start_period: 60s
```

## Secrets and security

- Do not bake credentials into the image. If you need to authenticate to Steam, set `STEAM_LOGIN` and pass `STEAM_PASSWORD`/`STEAM_GUARD` at runtime (Compose env vars, not committed).
- Likewise, set `SERVER_PASSWORD` and `SERVER_AUTH_SECRET` only via runtime env vars.

## Troubleshooting

- Executable not found: ensure `gameUpdate` ran successfully and the volume is mounted.
- Server not visible: check port forwarding and that `SERVER_VISIBLE=true`. Try disabling `UPNP_ENABLED` if your network blocks it.
- Connection issues: verify both TCP and UDP `GAME_PORT` are open on your host/firewall.
- Many warnings in log: Stationeers server is chatty; warnings are often expected.