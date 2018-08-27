#!/usr/bin/env bash

set -e

URL=${CI_SERVER_URL}/api/v4

EXISTING_RUNNERS=`curl --header "PRIVATE-TOKEN: ${PERSONAL_ACCESS_TOKENS}" "${URL}/runners/all" | \
    jq ".[] | select(.description == \"${RUNNER_NAME}\") | .id"`

for runner in ${EXISTING_RUNNERS}; do
    echo "Deleting existing runner: ${runner}"
    curl --request DELETE --header "PRIVATE-TOKEN: ${PERSONAL_ACCESS_TOKENS}" "${URL}/runners/${runner}"
done

RUNNER_TOKEN=`curl --request POST "${URL}/runners" \
    --form "token=${REGISTRATION_TOKEN}" \
    --form "description=${RUNNER_NAME}" \
    --form "tag_list=${RUNNER_TAG_LIST}" | \
    jq -r '.token'`

echo "Runner is registered with token: ${RUNNER_TOKEN}"

sed -i -e "s/_TOKEN_/${RUNNER_TOKEN}/g" ${CONFIG_FILE}
