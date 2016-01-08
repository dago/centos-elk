# centos-elk

~~~
docker run \
  -it \
  --name centos-elk-1 \
  --rm \
  -v /etc/machines/<machine>/ssl/httpd:/etc/ssl/httpd/ \
  -v /etc/machines/<machine>/httpd-config/sites-enabled:/etc/httpd/sites-enabled.d \
  -v /etc/machines/<machine>/elasticsearch-config/:/etc/elasticsearch/config/ \
  -v /etc/machines/<machine>/kibana-config/:/etc/kibana/config/ \
  centos-elk
~~~

