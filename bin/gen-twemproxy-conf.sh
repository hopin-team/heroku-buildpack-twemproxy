#!/usr/bin/env bash

rm -f /app/vendor/twemproxy/twemproxy.yml

echo "Setting REDIS_URL_TWENPROXY config var"
eval REDIS_URL_VALUE="${REDIS_URL}"

DB=$(echo "${REDIS_URL_VALUE}" | perl -lne 'print "$1 $2 $3 $4 $5 $6" if /^(rediss?)(?:ql)?:\/\/([^:]+):([^@]+)@(.*?):(.*?)(\\?.*)?$/')
DB_URI=( $DB )
DB_PROTO=${DB_URI[0]}
DB_USER=${DB_URI[1]}
DB_PASS=${DB_URI[2]}
DB_HOST=${DB_URI[3]}
DB_PORT=${DB_URI[4]}

NEW_URL=${DB_PROTO}://${DB_USER}:${DB_PASS}@127.0.0.1:6201
export REDIS_URL_TWEMPROXY=${NEW_URL}

echo "Pointing to ${DB_HOST}:${DB_PORT}"

cat >> /app/vendor/twemproxy/twemproxy.yml << EOFEOF
${REDIS_URL}:
  listen: 127.0.0.1:6201
  redis: true
  redis_auth: ${DB_PASS}
  timeout: 30000
  servers:
   - ${DB_HOST}:${DB_PORT}:1
EOFEOF

chmod go-rwx /app/vendor/twemproxy/*
