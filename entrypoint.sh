#!/bin/bash
set -e -o pipefail

if [[ `ls -A /opt/jdbc/*.jar 2>/dev/null` == '' ]]; then
  >&2 echo <<'EOF' 
You appear to be running the liquibase docker image without any drivers loaded
in /opt/jdbc.  You probably want to running an image with a database driver
already loaded.  Some images you may can try instead are:

https://hub.docker.com/r/kilna/liquibase-mysql/
https://hub.docker.com/r/kilna/liquibase-postgres/
https://hub.docker.com/r/kilna/liquibase-sqlite/

Replacement of ${...} values is disabled for liquibase.properties since it
needs environment variables which are handled by the database driver
specific docker images.
EOF
elif [[ `grep -F '${' liquibase.properties 2>/dev/null` != '' ]]; then
  echo "Replacing variables in liquibase.properties" >&2
  vars=( URL DATABASE HOST PORT USERNAME PASSWORD CHANGELOG LOGLEVEL )
  err=0
  for var in "${vars[@]}"; do
    lvar="LIQUIBASE_$var"
    eval "val=\${$lvar:-NULL}"
    if [[ `grep -F '${'$var'}' liquibase.properties` != '' ]]; then
      if [[ "$val" == 'NULL' ]]; then
        echo "\${$var} in liquibase.properties, but env var LIQUIBASE_$var was not set" >&2
        err=1
      else
        echo "Replacing \${$var} with env var LIQUIBASE_$var value '$val'" >&2
        sed -i 's/\${'${var}'}/'${val}'/g' liquibase.properties
      fi
    fi
  done
  if [[ "$err" == 0 ]]; then
    if [[ `grep -F '${' liquibase.properties` != '' ]]; then
      echo "Unrecognized replacement \${VARIABLE} in liquibase.properties" >&2
    fi
  fi
fi

exec "$@"

