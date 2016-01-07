FROM feduxorg/centos
MAINTAINER dev@fedux.org

ENV PG_MAJOR 9.4
ENV PGDATA /var/lib/pgsql/${PG_MAJOR}/data

RUN mkdir -p ${PGDATA} \
    && groupadd -r -g 990 postgres && useradd -r -g postgres -u 990 postgres \
    && chown -R postgres:postgres ${PGDATA}

USER postgres

VOLUME [${PGDATA}]

CMD ["true"]
