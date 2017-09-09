#!/bin/bash
set -e -o pipefail

is_true() { [[ "${1^^}" =~ ^(1|T|TRUE|Y|YES)$ ]]; }

if is_true "${LIQUIBASE_DEBUG}"; then
  set | grep LIQUIBASE_ >&2
fi

if ! is_true "${LIQUIBASE_DISABLE_DRIVER_CHECK}"; then
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

if ! is_true "${LIQUIBASE_DISABLE_INTERPOLATION}"; then
  varsubst -x LIQUIBASE_ -s -v liquibase.properties
fi

exec "$@"

