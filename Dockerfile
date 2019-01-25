FROM ubuntu:18.04
MAINTAINER Joosung Park <park012241@park012241.me>

ENV NGINX_VER 1.15.8
ENV OPENSSL_VER 1.1.1a

USER root
WORKDIR /root

RUN usermod www-data --home /etc/nginx --shell /sbin/nologin
RUN sed -i 's/archive.ubuntu.com/kr.archive.ubuntu.com/g' /etc/apt/sources.list && apt-get update && apt-get upgrade -y && apt-get autoclean && apt-get autoremove

RUN apt-get install -y libpcre3 libpcre3-dev zlib1g-dev && apt-get autoclean

RUN apt-get install -y wget build-essential && wget http://nginx.org/download/nginx-$NGINX_VER.tar.gz && wget https://www.openssl.org/source/openssl-$OPENSSL_VER.tar.gz && tar xzvf nginx-$NGINX_VER.tar.gz && rm -v nginx-$NGINX_VER.tar.gz && tar xzvf openssl-$OPENSSL_VER.tar.gz && rm -v openssl-$OPENSSL_VER.tar.gz && cd "/root/nginx-$NGINX_VER/" && ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' --with-openssl="$HOME/openssl-$OPENSSL_VER" --with-openssl-opt=enable-tls1_3 && make && make install && apt-get purge -y --auto-remove wget build-essential && rm -R "/root/nginx-$NGINX_VER" && rm -R "/root/openssl-$OPENSSL_VER"

RUN chown -R www-data:www-data /etc/nginx && chown -R www-data:www-data /var/log/nginx && mkdir -p /var/cache/nginx/ && chown -R www-data:www-data /var/cache/nginx/ && touch /run/nginx.pid && chown -R www-data:www-data /run/nginx.pid

RUN nginx -V

USER www-data
WORKDIR /etc/nginx

CMD ["nginx", "-g", "daemon off;"]

EXPOSE 80 443
