#!/bin/bash
set -o pipefail

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
else
  contents=$(<liquibase.properties)
  contents_orig="$contents"
  if [[ "$contents" ==  *'${'*'}'* ]]; then
    echo "Replacing variables in liquibase.properties" >&2
    vars=( URL DATABASE HOST PORT USERNAME PASSWORD CHANGELOG LOGLEVEL CLASSPATH DRIVER )
    err=0
    for var in "${vars[@]}"; do
      lvar="LIQUIBASE_$var"
      eval "val=\${$lvar:-NULL}"
      varmatch='${'$var'}'
      if [[ "$contents" == *"$varmatch"* ]]; then
        if [[ "$val" == 'NULL' ]]; then
          echo "\${$var} in liquibase.properties, but env var LIQUIBASE_$var was not set" >&2
          err=1
        else
          echo "Replacing \${$var} with env var LIQUIBASE_$var value '$val'" >&2
          contents=${contents//$varmatch/$val}
          #val_esc=${val//$/\\$}
          #val_esc=${val//{/\\{}
          #val_esc=${val_esc//\}/\\\}}
          #echo "ESCAPED: $val_esc"
          #sed -i 's/\${'${var}'}/'${val_esc}'/g' liquibase.properties
        fi
      fi
    done
    if [[ "$err" -ne 0 ]]; then
      if [[ "$contents" ==  *'${'*'}'* ]]; then
        echo "Unrecognized replacement variable \${...} in liquibase.properties" >&2
        err=1
      fi
    fi
    if [[ "$err" -ne 0 ]]; then
      echo "liquibase.properties contents before processing:" >&2
      echo "$contents_orig" >&2
      echo "liquibase.properties contents after processing:" >&2
      echo "$contents" >&2
    fi
    echo "$contents" > liquibase.properties
  fi
  unset contents contents_orig vars err val var varmatch lvar
fi

exec "$@"

