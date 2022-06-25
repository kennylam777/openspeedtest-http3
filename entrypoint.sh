#!/bin/sh

fallocate -l 30M /usr/share/nginx/html/downloading

sed -i "s/{HTTP_PORT}/${HTTP_PORT}/g" /etc/nginx/conf.d/OpenSpeedTest-Server-HTTP3.conf
sed -i "s/{HTTPS_PORT}/${HTTPS_PORT}/g" /etc/nginx/conf.d/OpenSpeedTest-Server-HTTP3.conf
sed -i "s/{QUIC_PORT}/${QUIC_PORT}/g" /etc/nginx/conf.d/OpenSpeedTest-Server-HTTP3.conf
sed -i "s/{QUIC_CC}/${QUIC_CC}/g" /etc/nginx/conf.d/OpenSpeedTest-Server-HTTP3.conf

echo "HTTP: ${HTTP_PORT} HTTPS: ${HTTPS_PORT} QUIC: ${QUIC_PORT} QUIC_CC: ${QUIC_CC}"

nginx -g 'daemon off;'