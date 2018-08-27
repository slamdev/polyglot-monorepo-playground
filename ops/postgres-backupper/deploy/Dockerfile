FROM alpine

RUN apk --update add postgresql-client bash \
 && rm -rf /var/lib/apt/lists/* \
 && rm /var/cache/apk/*

COPY backup.sh /usr/local/bin/backup

ENTRYPOINT ["backup"]
