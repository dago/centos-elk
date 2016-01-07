#!/bin/bash
set -e

#### FUNCTIONS

function set_listen_addresses() {
  sedEscapedValue="$(echo "$1" | sed 's/[\/&]/\\&/g')"
  sed -ri "s/^#?(listen_addresses\s*=\s*)\S+/\1'$sedEscapedValue'/" "$PGDATA/postgresql.conf"
}

function start_postgres() {
  directory=$1

  if systemctl status postgresql >/dev/null 2>&1; then
    return
  fi

  install -d -o postgres -g postgres /var/run/postgresql
  gosu postgres pg_ctl -D "$directory" -o "-c listen_addresses=''" -w start
}

function stop_postgres() {
  directory=$1

  if systemctl status postgresql  >/dev/null 2>&1; then
    return
  fi

  gosu postgres pg_ctl -D "$directory" -m fast -w stop
}

#### CHECK ENV VARIABLES

[[ -n "$PG_MAJOR" ]] || {
  echo 'Please make sure that the environment variable PG_MAJOR is set to something useful, e.g. 9.4' >&2
  exit 1
}

[[ -n "$PGDATA" ]] || {
  echo 'Please make sure that the environment variable PGDATA is set to something useful, e.g. /var/lib/pgsql/9.4/data' >&2
  exit 1
}

#### VARIABLES

PATH=/usr/pgsql-${PG_MAJOR}/bin:$PATH

export PG_MAJOR
export PGDATA
export PATH

#### SET MODE
#
# This should make the following code easier to read.
#
# $PGDATA/PG_VERSION is created by initdb. If this file exists the server has
# already been initialized.
#
# If the user passes POSTGRES_DB to the script assume, that the server has
# already been initialized and the user wants to add a new database only.

if [ ! -s "$PGDATA/PG_VERSION" -a -z "$POSTGRES_DB" ]; then
  MODE="firstrun"
else
  MODE="alreadyinitialized"
fi

#### USER DEFINED VARIABLES

: ${POSTGRES_PW:=$(uuidgen)}
: ${POSTGRES_DB:=postgres}
: ${POSTGRES_USER:=$POSTGRES_DB}
: ${POSTGRES_ENCODING:='UTF8'}

#### CHECK FOR ERRORS
#
# If postgresql has already been initialized, the user needs to pass either
# POSTGRES_DB or POSTGRES_USER to the script.

if [ $MODE == 'alreadyinitialized' -a -z "$POSTGRES_DB" -a -z "$POSTGRES_USER" ]; then
  cat >&2 <<-EOWARN
The database server and \"postgres\"-database have already been initialized.

To create a new database, run the following command. You need to add values for
the variables given down below.

# database and database user have different values
POSTGRES_USER= POSTGRES_PW= POSTGRES_DB= /usr/local/bin/pg-init.sh

# database and database user are the same
POSTGRES_USER= POSTGRES_PW= /usr/local/bin/pg-init.sh

# database and database user are the same and you want us to generate the password
POSTGRES_USER= /usr/local/bin/pg-init.sh
EOWARN
  exit 1
fi

if [ "$MODE" == 'firstrun' ]; then
  # Make postgres own PGDATA
  echo "Changing owner of $PGDATA to postgres:postgres" >&2
  chown -R postgres:postgres $PGDATA

  # Setup postgres
  echo "Initialize postgres" >&2
  gosu postgres initdb

  # Modify listen addresses
  echo "Set listeners" >&2
  set_listen_addresses '*'

  # check password first so we can ouptut the warning before postgres
  # messes it up
  echo $POSTGRES_PW > $PGDATA/.password
    cat >&2 <<-EOS
    ********************************************************
    *
    * WARNING: We saved the password  for the "postgres"-
    * database to the file "$PGDATA/.password." Please remove
    * the file after storing the password at a safe place.
    *
    ********************************************************
EOS

  # Start postgresql
  start_postgres $PGDATA

  psql --username postgres <<-EOS
  ALTER USER "postgres" WITH SUPERUSER PASSWORD '$POSTGRES_PW';
EOS

echo "Accepting connectiongs from everywhere" >&1
cat >> "$PGDATA"/pg_hba.conf <<-EOS

host all all 0.0.0.0/0 md5
EOS

  # Stop postgresql
  stop_postgres $PGDATA

  exit 0
fi

if [ "$MODE" == "alreadyinitialized" -a "$POSTGRES_DB" != "postgres" ]; then
  # Start postgresql
  start_postgres $PGDATA

  if [ "$POSTGRES_USER" != "postgres" ]; then
    echo "Creating role/user $POSTGRES_USER" >&2
    psql --username postgres <<-EOS
CREATE ROLE $POSTGRES_USER WITH LOGIN NOSUPERUSER NOCREATEDB PASSWORD '$POSTGRES_PW';
EOS
  fi

  if [ "$POSTGRES_DB" != "postgres" ]; then
    echo "Creating database $POSTGRES_DB" >&2
    psql --username postgres <<-EOS
CREATE DATABASE $POSTGRES_DB WITH OWNER $POSTGRES_USER ENCODING '$POSTGRES_ENCODING';
EOS
  fi

  # Stop postgresql
  stop_postgres $PGDATA
fi
