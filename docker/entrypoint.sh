#!/usr/bin/env bash
set -Eeuo pipefail

# Normalize line endings for the run script (in case repo was cloned on Windows)
sed -i 's/\r$//' /opt/stationeers/runstationeers-linux.sh || true

echo "[ENTRYPOINT] Timezone: ${TZ:-UTC}"

if [[ "${AUTO_UPDATE:-true}" =~ ^([Tt]rue|1|yes|Y)$ ]]; then
  echo "[ENTRYPOINT] Running SteamCMD update for app ${STEAMAPPID:-600760}"
  # Login: anonymous by default. If STEAM_LOGIN is set to a user, optional STEAM_PASSWORD and STEAM_GUARD can be provided at runtime (not baked in image)
  if [[ "${STEAM_LOGIN:-anonymous}" == "anonymous" ]]; then
    /home/steam/steamcmd/steamcmd.sh +force_install_dir /stationeers/gameServer +login anonymous +app_update ${STEAMAPPID:-600760} validate +quit
  else
    # Build a login command depending on provided secrets (not stored in the image)
    LOGIN_ARGS=("+login" "${STEAM_LOGIN}")
    if [[ -n "${STEAM_PASSWORD:-}" ]]; then LOGIN_ARGS+=("${STEAM_PASSWORD}"); fi
    if [[ -n "${STEAM_GUARD:-}" ]]; then LOGIN_ARGS+=("${STEAM_GUARD}"); fi
    /home/steam/steamcmd/steamcmd.sh +force_install_dir /stationeers/gameServer "${LOGIN_ARGS[@]}" +app_update ${STEAMAPPID:-600760} validate +quit
  fi
else
  echo "[ENTRYPOINT] AUTO_UPDATE disabled; skipping SteamCMD"
fi

echo "[ENTRYPOINT] Launching Stationeers server"
exec /opt/stationeers/runstationeers-linux.sh
