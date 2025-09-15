#!/usr/bin/env bash

set -Eeuo pipefail

###########################################################
# Stationeers Dedicated Server Entrypoint (Linux)
# Docs: https://stationeers-wiki.com/Dedicated_Server_Guide
# This script is env-driven and runs the server in foreground
# so Docker can manage lifecycle and signals properly.
###########################################################

# Directories and paths
DATA_DIR=${DATA_DIR:-/stationeers/gameData}
EXECUTABLE=${EXECUTABLE:-/stationeers/gameServer/rocketstation_DedicatedServer.x86_64}
SETTINGS_PATH=${SETTINGS_PATH:-"$DATA_DIR/settings.xml"}
SAVE_PATH=${SAVE_PATH:-"$DATA_DIR"}

# Server configuration (override via environment variables)
SERVER_NAME=${SERVER_NAME:-"Stationeers Server"}
SAVE_NAME=${SAVE_NAME:-savegamename}
WORLD_TYPE=${WORLD_TYPE:-Lunar}
SERVER_PASSWORD=${SERVER_PASSWORD:-}
SERVER_AUTH_SECRET=${SERVER_AUTH_SECRET:-}
GAME_PORT=${GAME_PORT:-27016}
START_LOCAL_HOST=${START_LOCAL_HOST:-true}
SERVER_VISIBLE=${SERVER_VISIBLE:-true}
UPNP_ENABLED=${UPNP_ENABLED:-true}
SERVER_MAX_PLAYERS=${SERVER_MAX_PLAYERS:-5}
AUTO_SAVE=${AUTO_SAVE:-true}
SAVE_INTERVAL=${SAVE_INTERVAL:-300}
DIFFICULTY=${DIFFICULTY:-Normal}
LOCAL_IP_ADDRESS=${LOCAL_IP_ADDRESS:-0.0.0.0}
LOG_TO_STDOUT=${LOG_TO_STDOUT:-true}
LOG_FILE=${LOG_FILE:-"$DATA_DIR/log.txt"}

# Ensure required directories exist
mkdir -p "$DATA_DIR"

# Basic validation
if [[ ! -x "$EXECUTABLE" ]]; then
    echo "[ERROR] Executable not found or not executable: $EXECUTABLE" >&2
    echo "Make sure game files are downloaded to /stationeers/gameServer before starting." >&2
    exit 1
fi

# Configure logging: to stdout (recommended) or file
LOG_FILE_ARG="-logFile -"
if [[ "${LOG_TO_STDOUT,,}" != "true" ]]; then
    # Log to file when explicitly disabled
    : > "$LOG_FILE"  # create/empty file
    LOG_FILE_ARG="-logFile $LOG_FILE"
fi

echo "[INFO] Starting Stationeers Dedicated Server"
echo "[INFO] Data dir: $DATA_DIR"
echo "[INFO] Save name: $SAVE_NAME | World: $WORLD_TYPE | Difficulty: $DIFFICULTY"
echo "[INFO] Port: $GAME_PORT | Visible: $SERVER_VISIBLE | Max players: $SERVER_MAX_PLAYERS"
echo "[INFO] Logging to: ${LOG_FILE_ARG#-logFile }"

# Run the server in the foreground so PID 1 is the game process
exec "$EXECUTABLE" \
    -nographics \
    -batchmode \
    -loadlatest "$SAVE_NAME" "$WORLD_TYPE" \
    $LOG_FILE_ARG \
    -settingspath "$SETTINGS_PATH" \
    -difficulty "$DIFFICULTY" \
    -settings StartLocalHost "$START_LOCAL_HOST" ServerVisible "$SERVER_VISIBLE" \
        GamePort "$GAME_PORT" UPNPEnabled "$UPNP_ENABLED" ServerName "$SERVER_NAME" \
        ServerPassword "$SERVER_PASSWORD" ServerMaxPlayers "$SERVER_MAX_PLAYERS" \
        AutoSave "$AUTO_SAVE" SaveInterval "$SAVE_INTERVAL" \
        SavePath "$SAVE_PATH" \
        ServerAuthSecret "$SERVER_AUTH_SECRET" \
        LocalIpAddress "$LOCAL_IP_ADDRESS"

