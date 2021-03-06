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
    && rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

RUN yum install -y elasticsearch
RUN yum install -y logstash
RUN yum install -y httpd
RUN yum install -y java-1.8.0-openjdk

RUN install -d -o kibana -g kibana -m 0755 /srv/kibana \
    && install -d -o kibana -g kibana -m 0755 /var/log/kibana \
    && install -d -o elasticsearch -g elasticsearch -m 0700 /usr/share/elasticsearch/data \
    && install -d -o elasticsearch -g elasticsearch -m 0755 /usr/share/elasticsearch/logs \
    && install -d -o httpd -g httpd -m 0755 /etc/httpd/sites-enabled.d

RUN curl -L https://download.elastic.co/kibana/kibana/kibana-${KB_VERSION}-linux-x64.tar.gz | tar --strip-components=1 -xzf - -C /srv/kibana \
    && chown -R kibana:kibana /srv/kibana \
    && systemctl enable elasticsearch \
    && systemctl enable kibana \
    && systemctl enable httpd \
    && sed -i -e "s#network\.host: .*#network.host: localhost#" /etc/elasticsearch/elasticsearch.yml \
    && yum clean -y all

ADD kibana.yml /srv/kibana/config/kibana.yml

EXPOSE 80 443

VOLUME ["/etc/httpd/sites-enabled.d", "/usr/share/elasticsearch/data", "/usr/share/elasticsearch/logs"]
