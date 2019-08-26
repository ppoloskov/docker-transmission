FROM alpine:3.10
MAINTAINER Paul Poloskov <pavel@poloskov.net>

ENV PUID 1001
ENV PGID 1001
ENV SETTINGS "/config/settings.json"

RUN apk --no-cache add curl transmission-daemon && \
    addgroup -g ${PGID} notroot && \
    adduser -D -H -G notroot -u ${PUID} notroot && \
    mkdir /config /downloads /watch /incomplete && \
    chown notroot:notroot /config /downloads /watch /incomplete && \
    echo -e '{\n    "blocklist-enabled": 0,' > $SETTINGS && \
    echo '    "pex-enabled": 1,' >> $SETTINGS && \
    echo '    "rename-partial-files": true, ' >> $SETTINGS && \
    echo '    "rpc-authentication-required": false,' >> $SETTINGS && \
    echo '    "rpc-enabled": true, ' >> $SETTINGS && \
    echo '    "rpc-host-whitelist-enabled": false, ' >> $SETTINGS && \
    echo '    "rpc-host-whitelist": "*", ' >> $SETTINGS && \
    echo '    "rpc-port": 9091,' >> $SETTINGS && \
    echo '    "rpc-url": "/transmission/",' >> $SETTINGS && \
    echo '    "rpc-username": "", ' >> $SETTINGS && \
    echo '    "rpc-whitelist-enabled": true, ' >> $SETTINGS && \
    echo '    "rpc-whitelist": "*", ' >> $SETTINGS && \
    echo '    "trash-original-torrent-files": true, ' >> $SETTINGS && \
    echo '    "umask": 2,' >> $SETTINGS && \
    echo -e '    "upload-limit-enabled": 0\n}' >> $SETTINGS

EXPOSE 9091 51413/tcp 51413/udp

HEALTHCHECK CMD netstat -an | grep 9091 > /dev/null; if [ 0 != $? ]; then exit 1; fi;

VOLUME ["/config" "/downloads" "/watch" "/incomplete"]

USER notroot

ENTRYPOINT [ "/usr/bin/transmission-daemon" ]
CMD [ "--rpc-bind-address", "0.0.0.0", \
    "--dht", \
    "--download-dir", "/downloads", \
    "--foreground", \
    "--watch-dir", "/watch", \
    "--config-dir", "/config", \
    "--incomplete-dir", "/incomplete", \
    "--no-auth", \
    "--log-error", \
    "--utp", \
    "--encryption-required" ]
