#!/usr/bin/env bash
set -Eeuo pipefail

# Normalize line endings for the run script (in case repo was cloned on Windows)
sed -i 's/\r$//' /opt/stationeers/runstationeers-linux.sh || true

echo "[ENTRYPOINT] Timezone: ${TZ:-UTC}"

if [[ "${AUTO_UPDATE:-true}" =~ ^([Tt]rue|1|yes|Y)$ ]]; then
  echo "[ENTRYPOINT] Running SteamCMD update for app ${STEAMAPPID:-600760}"
  STEAMCMD_BIN="/home/steam/steamcmd/steamcmd.sh"
  INSTALL_DIR="/stationeers/gameServer"
  APPID="${STEAMAPPID:-600760}"
  VALIDATE_FLAG="${STEAMCMD_VALIDATE:-true}"

  # Build login args
  if [[ "${STEAM_LOGIN:-anonymous}" == "anonymous" ]]; then
    LOGIN_ARGS=("+login" "anonymous")
  else
    LOGIN_ARGS=("+login" "${STEAM_LOGIN}")
    if [[ -n "${STEAM_PASSWORD:-}" ]]; then LOGIN_ARGS+=("${STEAM_PASSWORD}"); fi
    if [[ -n "${STEAM_GUARD:-}" ]]; then LOGIN_ARGS+=("${STEAM_GUARD}"); fi
  fi

  # Prepare app_update args
  APP_UPDATE_ARGS=("+app_update" "$APPID")
  if [[ "$VALIDATE_FLAG" =~ ^([Tt]rue|1|yes|Y)$ ]]; then
    APP_UPDATE_ARGS+=("validate")
  fi

  # Retry update once on failure; treat non-zero exit as non-fatal if server already installed
  set +e
  UPDATE_RC=0
  for attempt in 1 2; do
    echo "[ENTRYPOINT] SteamCMD attempt ${attempt}: updating app ${APPID}"
    "$STEAMCMD_BIN" +force_install_dir "$INSTALL_DIR" "${LOGIN_ARGS[@]}" "${APP_UPDATE_ARGS[@]}" +quit
    UPDATE_RC=$?
    if [[ $UPDATE_RC -eq 0 ]]; then
      break
    fi
    echo "[ENTRYPOINT] SteamCMD exited with code ${UPDATE_RC} on attempt ${attempt}."
    sleep 3
  done

  if [[ $UPDATE_RC -ne 0 ]]; then
    # If server files exist, proceed despite SteamCMD complaint (e.g., state 0x6)
    if [[ -x "$INSTALL_DIR/rocketstation_DedicatedServer.x86_64" ]] || [[ -f "/stationeers/steamapps/appmanifest_${APPID}.acf" ]]; then
      echo "[ENTRYPOINT] Warning: SteamCMD update returned ${UPDATE_RC}, but server files are present. Proceeding to launch."
    else
      echo "[ENTRYPOINT] Error: SteamCMD failed (${UPDATE_RC}) and no server files found at $INSTALL_DIR. Exiting."
      exit $UPDATE_RC
    fi
  fi
  set -e
else
  echo "[ENTRYPOINT] AUTO_UPDATE disabled; skipping SteamCMD"
fi

echo "[ENTRYPOINT] Launching Stationeers server"
exec /opt/stationeers/runstationeers-linux.sh
