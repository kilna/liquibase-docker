#!/bin/bash
set -e -o pipefail

echo "Verifying error when running without driver"
export LIQUIBASE_DISABLE_DRIVER_CHECK=yes
if [[ ! `/usr/local/bin/entrypoint.sh /bin/true 2>&1` =~ '^You appear' ]]; then
  echo 'No error returned when attempting to run entrypoint.sh with no drivers' >&2
  exit 1
fi

echo "Installing sqlite driver"
# Cribbed from kilna/liquibase-sqlite-docker
sqlite_jdbc_version=3.20.0
sqlite_jdbc_download_url=https://bitbucket.org/xerial/sqlite-jdbc/downloads
export LIQUIBASE_CLASSPATH=${LIQUIBASE_CLASSPATH:-/opt/jdbc/sqlite-jdbc.jar}\
export LIQUIBASE_DRIVER=${LIQUIBASE_DRIVER:-org.sqlite.JDBC}\
export LIQUIBASE_URL=${LIQUIBASE_URL:-'jdbc:sqlite:${DATABASE}'}
cd /opt/jdbc
jarfile=sqlite-jdbc-${sqlite_jdbc_version}.jar
curl -SOLs ${sqlite_jdbc_download_url}/${jarfile}
ln -s ${jarfile} sqlite-jdbc.jar

echo "Adding sqlite"
apk --no-cache add sqlite

echo "Creating sqlite db"
sqlite3 liquibase .databases

echo "Applying changelog"
/usr/local/bin/entrypoint.sh liquibase --changeLogFile=/opt/test_liquibase/changelog.xml updateTestingRollback

