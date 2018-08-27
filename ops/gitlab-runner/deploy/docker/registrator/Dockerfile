FROM alpine

RUN apk --update add jq curl bash \
 && rm -rf /var/lib/apt/lists/* \
 && rm /var/cache/apk/*

COPY registrator.sh /usr/local/bin/registrator

ENTRYPOINT ["registrator"]
