FROM feduxorg/centos
MAINTAINER dev@fedux.org

RUN groupadd -g 990 -r elasticsearch \
    && useradd -r -g elasticsearch -u 990 elasticsearch \
    && groupadd -g 991 -r kibana \
    && useradd -r -g kibana -u 991 kibana \
    && groupadd -g 992 -r logstash \
    && useradd -r -g logstash -u 992 logstash \
    && groupadd -g 993 -r httpd \
    && useradd -r -g httpd -u 993 httpd

RUN install -d -o kibana -g kibana -m 0755 /srv/kibana \
    && install -d -o kibana -g kibana -m 0755 /var/log/kibana \
    && install -d -o elasticsearch -g elasticsearch -m 0700 /usr/share/elasticsearch/data \
    && install -d -o elasticsearch -g elasticsearch -m 0755 /usr/share/elasticsearch/logs \
    && install -d -o httpd -g httpd -m 0755 /etc/httpd/sites-enabled.d

CMD ["true"]
