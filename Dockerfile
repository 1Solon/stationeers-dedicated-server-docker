FROM cm2network/steamcmd:latest

LABEL org.opencontainers.image.title="Stationeers Dedicated Server"
LABEL org.opencontainers.image.source="https://github.com/mandusm/stationeers-dedicated-server"

# Environment defaults (override at runtime)
ENV STEAMAPPID=600760 \
    STEAM_LOGIN=anonymous \
    AUTO_UPDATE=true \
    TZ=UTC \
    DATA_DIR=/stationeers/gameData \
    EXECUTABLE=/stationeers/gameServer/rocketstation_DedicatedServer.x86_64 \
    SETTINGS_PATH=/stationeers/gameData/settings.xml \
    SAVE_PATH=/stationeers/gameData \
    SERVER_NAME="Stationeers Server" \
    SAVE_NAME=savegamename \
    WORLD_TYPE=Lunar \
    GAME_PORT=27016 \
    START_LOCAL_HOST=true \
    SERVER_VISIBLE=true \
    UPNP_ENABLED=true \
    SERVER_MAX_PLAYERS=5 \
    AUTO_SAVE=true \
    SAVE_INTERVAL=300 \
    DIFFICULTY=Normal \
    LOCAL_IP_ADDRESS=0.0.0.0 \
    LOG_TO_STDOUT=true

# Create and own persistent directory. The base image uses user steam:steam
USER root
RUN set -eux; \
    mkdir -p /stationeers/gameServer /stationeers/gameData; \
    chown -R steam:steam /stationeers

USER steam
WORKDIR /home/steam

# Copy run script and entrypoint
COPY --chown=steam:steam data/runstationeers-linux.sh /opt/stationeers/runstationeers-linux.sh
COPY --chown=steam:steam docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /opt/stationeers/runstationeers-linux.sh /entrypoint.sh

# Persist server files and data
VOLUME ["/stationeers"]

# Expose default Stationeers port (both TCP and UDP)
EXPOSE 27016/tcp 27016/udp

ENTRYPOINT ["/entrypoint.sh"]
