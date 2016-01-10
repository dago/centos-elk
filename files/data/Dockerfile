FROM feduxorg/centos
MAINTAINER dev@fedux.org

#ENV PG_MAJOR 9.4
#ENV PGDATA /var/lib/pgsql/${PG_MAJOR}/data

RUN mkdir -p ${PGDATA} \
    && groupadd -r -g 990 elk && useradd -r -g elk -u 990 elk \
    && chown -R elk:elk ${PGDATA}

USER elk

#VOLUME [${PGDATA}]

CMD ["true"]
