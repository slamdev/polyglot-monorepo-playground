FROM alpine

RUN apk --update add postgresql-client bash \
 && rm -rf /var/lib/apt/lists/* \
 && rm /var/cache/apk/*

COPY restore.sh /usr/local/bin/restore

ENTRYPOINT ["restore"]
