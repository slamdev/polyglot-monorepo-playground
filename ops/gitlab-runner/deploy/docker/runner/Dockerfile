FROM gitlab/gitlab-runner:alpine

RUN apk upgrade --no-cache \
# Install common tools
 && apk add --no-cache curl jq

COPY shutdown.sh /opt/
