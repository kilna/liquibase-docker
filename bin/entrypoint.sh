#!/bin/bash
set -e -o pipefail

if [[ "${LIQUIBASE_DEBUG^^}" =~ '^[1YT]' ]]; then
  set | grep LIQUIBASE_ >&2
fi

if [[ ! "${LIQUIBASE_DISABLE_DRIVER_CHECK}" == 'yes' ]]; then
  if [[ `ls -A /opt/jdbc/*.jar 2>/dev/null` == '' ]]; then
    >&2 cat <<'EOF' 
You appear to be running the liquibase docker image without any drivers
in /opt/jdbc.  You probably want to running an image with a database driver
already loaded.  Some images you may can try instead are:

https://hub.docker.com/r/kilna/liquibase-mysql/
https://hub.docker.com/r/kilna/liquibase-mariadb/
https://hub.docker.com/r/kilna/liquibase-postgres/
https://hub.docker.com/r/kilna/liquibase-sqlite/

Replacement of ${...} values is disabled for liquibase.properties, since it
needs environment variables which are set by the driver-specific docker
images.
EOF
    LIQUIBASE_DISABLE_INTERPOLATION=yes
  fi
fi

if [[ ! "${LIQUIBASE_DISABLE_INTERPOLATION}" == 'yes' ]]; then
  /usr/local/bin/varsubst --prefix LIQUIBASE_ --strict liquibase.properties
fi

exec "$@"

