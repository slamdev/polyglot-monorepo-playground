FROM alpine:3.8

RUN apk --update add postgresql-client bash \
 && rm -rf /var/lib/apt/lists/* \
 && rm /var/cache/apk/*

COPY backup.sh /usr/local/bin/backup
COPY restore.sh /usr/local/bin/restore
