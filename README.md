# centos-ruby

## Overview

There are the following images available:

* latest
* data

## Tasks

### Build image

~~~
rake docker:build
# or simply
rake
~~~

### Run database

~~~
# Without data container
PG_MAJOR=9.4
docker run -ti --rm --name "centos-postgres1" -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v $(pwd)tmp/storage:/var/lib/pgsql/${PG_MAJOR}/data -v $(pwd)tmp/log:/var/log/postgresql -v /var/log/journal:/var/log/journal -p 5432:5432 feduxorg/centos-postgresql

# With data container
PG_MAJOR=9.4
docker run -ti --rm --name "centos-postgres1" -v /sys/fs/cgroup:/sys/fs/cgroup:ro --volumes-from "centos-postgres1-data" -p 5432:5432 feduxorg/centos-postgresql
~~~

### Create data container

~~~bash
# Run data container
PG_MAJOR=9.4
docker create --name "centos-postgres1-data" -v $(pwd)/tmp/storage:/var/lib/pgsql/${PG_MAJOR}/data -v $(pwd)/tmp/log:/var/log/postgresql -v /var/log/journal:/var/log/journal feduxorg/centos-postgresql:data true

# Run data container with backup directory (required if you want the backup service to run daily)
PG_MAJOR=9.4
docker create --name "centos-postgres1-data" -it -v $(pwd)/tmp/storage:/var/lib/pgsql/${PG_MAJOR}/data -v $(pwd)/tmp/backup:/srv/backup/database -v $(pwd)/tmp/log:/var/log/postgresql -v /var/log/journal:/var/log/journal feduxorg/centos-postgresql:data true
~~~

### Create database

~~~bash
# Run from within other container
docker exec -it --name centos-postgres1 bash
POSTGRES_USER=myapp POSTGRES_PW=asdfkasdf POSTGRES_DB=myapp_production /usr/local/bin/pg-init.sh
~~~

### Create backups from your databases

If you mount a directory to `/srv/backup/database` a cron job runs once a day
and backups all your databases. This also activates the cleanup task. Both are
controlled via a `.timer`-unit.

~~~
PG_MAJOR=9.4
docker run -ti --rm --name "centos-postgres1" -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v $(pwd)/tmp/storage:/var/lib/pgsql/${PG_MAJOR}/data -v $(pwd)/tmp/backup:/srv/backup/database -v $(pwd)tmp/log:/var/log/postgresql -v /var/log/journal:/var/log/journal -p 5432:5432 feduxorg/centos-postgresql
~~~

## Further description of images

### Services

* `pg-backup`: Run daily and backup all databases
* `pg-backup-cleanup`: Cleanup old backups daily
* `pg-init`: Run once on very early startup
* `postgresql-<x.x>`: Database server
