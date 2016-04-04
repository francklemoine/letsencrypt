#!/bin/bash

set -e

if [[ -z "${EMAIL}" ]]; then
	echo >&2 'Notice: undefined variable EMAIL! - skipping ...'
	exit 1
fi


if [[ -z "${DOMAIN}" ]]; then
	echo >&2 'Notice: undefined variable DOMAIN! - skipping ...'
	exit 1
fi


EMAIL="${EMAIL//[[:space:]]/}"
DOMAIN="${DOMAIN//[[:space:]]/}"


if [ ! -f "/firstrun_${DOMAIN}" ]; then
	[ -f "/etc/cron.d/${DOMAIN}" ] && rm -f /etc/cron.d/${DOMAIN}
	echo -e "30 3 * * 0 /opt/letsencrypt/letsencrypt-auto renew --no-self-upgrade >>/var/log/letsencrypt.log\n" >/etc/cron.d/${DOMAIN}

	# letsencrypt cert
	if /opt/letsencrypt/letsencrypt-auto certonly \
	                                  --no-self-upgrade \
	                                  --agree-tos \
	                                  --email ${EMAIL} \
	                                  --rsa-key-size 4096 \
	                                  --webroot \
	                                  --webroot-path /var/www/${DOMAIN} \
	                                  --domain ${DOMAIN} \
	                                  --staging
	then
		# Echo quickstart guide to logs
		echo
		echo '================================================================================='
		echo "Your ${DOMAIN} letsencrypt container is now ready to use!"
		echo '================================================================================='
		echo

		# Used as identifier for first-run-only stuff
		touch /firstrun_${DOMAIN}
	else
		echo
		echo '================================================================================='
		echo "Your ${DOMAIN} letsencrypt container can't get certificates!"
		echo '================================================================================='
		echo
	fi
fi

/usr/sbin/cron -f -L 15

