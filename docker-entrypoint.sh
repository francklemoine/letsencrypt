#!/bin/bash

set -e

MAXDOMAIN=4

# set EMAIL and DOMAIN arrays
for (( i=1; i<=${MAXDOMAIN}; i++ )); do
	if [[ -v EMAIL${i} && -v DOMAIN${i} ]]; then
		fullmai="EMAIL${i}"
		fulldom="DOMAIN${i}"
	 	EMAIL_ARRAY[${i}]=${!fullmai//[[:space:]]/}
	 	DOMAIN_ARRAY[${i}]=${!fulldom//[[:space:]]/}
	fi
done


# one email/domain at least must be defined
if [[ -z "${EMAIL_ARRAY[*]}" || -z "${DOMAIN_ARRAY[*]}" ]]; then
	echo >&2 'Notice: undefined variable(s) EMAIL1..9 or DOMAIN1..9! - skipping ...'
	exit 1
fi


for (( i=1; i<=${#DOMAIN_ARRAY[@]}; i++ )); do
	if [[ ! -f "/firstrun_${DOMAIN_ARRAY[$i]}" ]]; then
		[[ -f "/etc/cron.d/${DOMAIN_ARRAY[$i]/./-}" ]] && rm -f /etc/cron.d/${DOMAIN_ARRAY[$i]/./-}
		echo -e "30 ${i} * * 0 root /opt/letsencrypt/letsencrypt-auto renew --no-self-upgrade >>/var/log/letsencrypt_${DOMAIN_ARRAY[$i]}.log\n" >>/etc/cron.d/${DOMAIN_ARRAY[$i]/./-}

		[[ -d /var/www/${DOMAIN_ARRAY[$i]} ]] || mkdir /var/www/${DOMAIN_ARRAY[$i]}

		# letsencrypt cert
		if /opt/letsencrypt/letsencrypt-auto certonly \
			                              --no-self-upgrade \
			                              --agree-tos \
			                              --email ${EMAIL_ARRAY[$i]} \
			                              --rsa-key-size 4096 \
			                              --webroot \
			                              --webroot-path /var/www/${DOMAIN_ARRAY[$i]} \
			                              --domain ${DOMAIN_ARRAY[$i]}
		then
			# Echo quickstart guide to logs
			echo
			echo '================================================================================='
			echo "Your ${DOMAIN_ARRAY[$i]} letsencrypt container is now ready to use!"
			echo '================================================================================='
			echo

			# Used as identifier for first-run-only stuff
			touch /firstrun_${DOMAIN_ARRAY[$i]}
		else
			echo
			echo '================================================================================='
			echo "Your ${DOMAIN_ARRAY[$i]} letsencrypt container can't get certificates!"
			echo '================================================================================='
			echo
		fi
	fi
done

/usr/sbin/cron -f -L 15

