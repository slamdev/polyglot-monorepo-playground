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

function contains {
    local item=${1}
    local array=${2}
    for e in ${array}; do
        if [ "${item}" = "${e}" ]; then
            return 0
        fi
    done
    return 1
}

function backup {
    local db=${1}
    # TODO add proper backup
    echo "pg_dump ${CONNECTION} --no-owner --no-acl -Ft ${db} > ${PG_BACKUP_DIR}/${db}.tar"
}

function backup_special {
    local db=${1}
    backup ${db}
    drop_if_exists "${db}-bak"
    createdb ${CONNECTION} -T template1 "${db}-bak"
    pg_restore ${CONNECTION} -Ft -d "${db}-bak" ${PG_BACKUP_DIR}/${db}.tar
    prepare_${db} "${db}-bak"
    backup "${db}-bak"
    mv ${BACKUP_DIR}/${db}-bak.tar ${PG_BACKUP_DIR}/${db}.tar
    drop_if_exists "${db}-bak"
}

function prepare_example-db {
    local db=${1}
    sql "${db}" "SELECT 1"
}

#PG_BACKUP_DIR=build
#PG_HOST=localhost
#PG_PORT=5432
#PG_USER=postgres
#PG_PASSWORD=postgres
export PGPASSWORD=${PG_PASSWORD}
CONNECTION="--host=${PG_HOST} --port=${PG_PORT} --username=${PG_USER}"
SKIP_DATABASES="postgres template1 template0"
SPECIAL_DATABASES="example-db"
ALL_DATABASES=`sql "postgres" "SELECT datname FROM pg_database"`

mkdir -p ${PG_BACKUP_DIR}

for db in ${ALL_DATABASES}; do
    if contains "${db}" "${SKIP_DATABASES}" ; then
        echo "$(date +"%T"): skip ${db}"
    elif contains "${db}" "${SPECIAL_DATABASES}" ; then
        echo "$(date +"%T"): special backup ${db}"
        backup_special ${db}
    else
        echo "$(date +"%T"): backup ${db}"
        backup ${db}
    fi
done
