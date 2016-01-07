#!/usr/bin/env bash

: ${PG_BACKUP_USER:=postgres}
: ${PG_BACKUP_GROUP:=$PG_BACKUP_USER}
: ${PG_BACKUP_DIRECTORY:=/srv/backup/database}
: ${PG_KEEP_FILES_YOUNGER_THAN_DAYS:=30}

if [ -d $PG_BACKUP_DIRECTORY ]; then
  chown -R $PG_BACKUP_USER:$PG_BACKUP_GROUP $PG_BACKUP_DIRECTORY
else
  echo "Backup-directory \"${PG_BACKUP_DIRECTORY}\" does not exist. I'm going to create it." >&2
  install -d -o $PG_BACKUP_USER -g $PG_BACKUP_GROUP $PG_BACKUP_DIRECTORY
fi

find $PG_BACKUP_DIRECTORY -mtime "+${PG_KEEP_FILES_YOUNGER_THAN_DAYS}" -delete
