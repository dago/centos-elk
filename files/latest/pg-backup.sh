#!/usr/bin/env bash

: ${PG_BACKUP_DIRECTORY:=/srv/backup/database}
: ${PG_BACKUP_TIMESTAMP:=$(date '+%Y%m%d_%H%M%S')}
: ${PG_BACKUP_USER:=postgres}
: ${PG_BACKUP_GROUP:=$PG_BACKUP_USER}
: ${PG_KEEP_FILES_YOUNGER_THAN_DAYS:=30}

if ! which pg_dumpall >/dev/null 2>&1; then
  echo '"pg_dumpall" not found in PATH' >&2
  exit 1
fi

if [ -d $PG_BACKUP_DIRECTORY ]; then
  chown -R $PG_BACKUP_USER:$PG_BACKUP_GROUP $PG_BACKUP_DIRECTORY
else
  echo "Backup-directory \"${PG_BACKUP_DIRECTORY}\" does not exist. I'm going to create it." >&2
  install -d -o $PG_BACKUP_USER -g $PG_BACKUP_GROUP $PG_BACKUP_DIRECTORY
fi

echo "Creating backup \"${PG_BACKUP_DIRECTORY}/${PG_BACKUP_TIMESTAMP}.sql.gz\"." >&2
pg_dumpall --user $PG_BACKUP_USER | gzip > ${PG_BACKUP_DIRECTORY}/${PG_BACKUP_TIMESTAMP}.sql.gz
chown -R $PG_BACKUP_USER:$PG_BACKUP_GROUP ${PG_BACKUP_DIRECTORY}/${PG_BACKUP_TIMESTAMP}.sql.gz

if [ $? -eq 0 ]; then
  echo 'Backup: Success.' >&2
else
  echo 'Backup: Failure.' >&2
fi
