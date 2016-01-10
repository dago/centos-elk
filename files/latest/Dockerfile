FROM feduxorg/centos:latest
MAINTAINER fedux.org

ENV KB_VERSION 4.3.1

ADD repository-elk.repo /etc/yum.repos.d/elk.repo
ADD kibana.service /etc/systemd/system/kibana.service
ADD http-enable.conf /etc/httpd/conf.d/enabled-sites.conf

# Install postgres
RUN groupadd -g 990 -r elasticsearch \
    && useradd -r -g elasticsearch -u 990 elasticsearch \
    && groupadd -g 991 -r kibana \
    && useradd -r -g kibana -u 991 kibana \
    && groupadd -g 992 -r logstash \
    && useradd -r -g logstash -u 992 logstash \
    && groupadd -g 993 -r httpd \
    && useradd -r -g httpd -u 993 httpd \
    && rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch \
    && yum install -y elasticsearch logstash httpd java-1.8.0-openjdk

RUN install -d -o kibana -g kibana -m 0755 /srv/kibana \
    && install -d -o kibana -g kibana -m 0755 /var/log/kibana \
    && install -d -o elasticsearch -g elasticsearch -m 0700 /usr/share/elasticsearch/data \
    && install -d -o httpd -g httpd -m 0755 /etc/httpd/sites-enabled.d \
    && curl -L https://download.elastic.co/kibana/kibana/kibana-${KB_VERSION}-linux-x64.tar.gz | tar --strip-components=1 -xzf - -C /srv/kibana \
    && chown -R kibana:kibana /srv/kibana \
    && systemctl enable elasticsearch \
    && systemctl enable kibana \
    && systemctl enable httpd \
    #&& mkdir -p ${PGDATA} \
    #&& mkdir -p /run/postgresql \
    #&& chown -R postgres ${PGDATA} \
    #&& chmod g+s /run/postgresql \
    #&& chown -R postgres:postgres /run/postgresql \
    && yum clean -y all

ADD kibana.yml /srv/kibana/config/kibana.yml

## Add cleanup backup service
#ADD e-cleanup.service /etc/systemd/system/e-cleanup.service
#ADD e-cleanup.timer /etc/systemd/system/e-cleanup.timer
#ADD e-cleanup.sh /usr/local/bin/e-cleanup.sh
#
#RUN  chmod +x /usr/local/bin/e-cleanup.sh \
#  && systemctl enable e-cleanup.timer

#ADD profile.d-environment.sh /etc/profile.d/99-environment.sh
#ADD environment.db /etc/pg/environment.db

#EXPOSE 5432
EXPOSE 80 443
#VOLUME ["/var/lib/pgsql/${PG_MAJOR}/data", "/srv/backup"]
VOLUME ["/etc/httpd/sites-enabled.d", "/usr/share/elasticsearch/data"]
