# DESCRIPTION: letsencrypt within a container
# BUILD:       docker build -t flem/letsencrypt .
# RUN:         docker run -d \
#                         -e EMAIL=user@domain.tld
#                         -e DOMAIN=www.domain.tld
#                         flem/letsencrypt


FROM debian:jessie
MAINTAINER Franck Lemoine <franck.lemoine@flem.fr>

# properly setup debian sources
ENV DEBIAN_FRONTEND=noninteractive

RUN buildDeps=' \
		git \
		cron \
	' \
	set -x \
	&& test -z ${http_proxy}  || /bin/echo -e "Acquire::http::proxy \"${http_proxy}\";\n" >>/etc/apt/apt.conf \
	&& test -z ${https_proxy} || /bin/echo -e "Acquire::https::proxy \"${https_proxy}\";\n" >>/etc/apt/apt.conf \
	&& apt-get -y update \
	&& apt-get -y upgrade \
	&& apt-get install -y --no-install-recommends $buildDeps

RUN git config --global http.sslVerify false \
    && git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt \
	&& /opt/letsencrypt/letsencrypt-auto --os-packages-only \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/*

COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

VOLUME ["/etc/letsencrypt", "/var/www"]

ENTRYPOINT ["/docker-entrypoint.sh"]
