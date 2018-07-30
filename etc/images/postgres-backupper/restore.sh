#!/usr/bin/env bash

set -e

function sql {
    local db=${1}
    local command=${2}
    psql ${CONNECTION} -t -d ${db} -c "${command}"
}

function drop_if_exists {
    local db=${1}
    local exists=`sql "postgres" "SELECT datname FROM pg_database WHERE datname = '${db}'"`
    if [[ -n ${exists} ]]; then
        dropdb ${CONNECTION} ${db}
    fi
}

function restore {
    local db=${1}
    drop_if_exists "${db}"
    createdb ${CONNECTION} -T template1 "${db}"
    pg_restore ${CONNECTION} --no-owner -Ft -d "${db}" ${PG_BACKUP_DIR}/${db}.tar
}

function wait_until_ready {
    until pg_isready ${CONNECTION};
        do sleep 1;
    done
}

#PG_BACKUP_DIR=build
#PG_HOST=localhost
#PG_PORT=5432
#PG_USER=postgres
#PG_PASSWORD=postgres
export PGPASSWORD=${PG_PASSWORD}
CONNECTION="--host=${PG_HOST} --port=${PG_PORT} --username=${PG_USER}"

mkdir -p ${PG_BACKUP_DIR}

ALL_DATABASES=`ls ${PG_BACKUP_DIR}`

#
# Ensures that postgres pod is ready for connection; since there is a double startup problem
# with postgres image, wait should be done twice https://github.com/docker-library/postgres/issues/146
#
wait_until_ready
sleep 10
wait_until_ready

echo "Postgres is ready for restoring"

for db in ${ALL_DATABASES}; do
        echo "$(date +"%T"): restore ${db}"
        restore ${db%%.tar}
done
