# liquibase-docker

[![](https://images.microbadger.com/badges/image/kilna/liquibase.svg)](https://microbadger.com/images/kilna/liquibase)
[![](https://img.shields.io/docker/pulls/kilna/liquibase.svg?style=plastic)](https://hub.docker.com/r/kilna/liquibase/)
[![](https://img.shields.io/docker/stars/kilna/liquibase.svg?style=plastic)](https://hub.docker.com/r/kilna/liquibase/)
[![](https://img.shields.io/badge/docker_build-automated-blue.svg?style=plastic)](https://cloud.docker.com/swarm/kilna/repository/docker/kilna/liquibase/builds)
[![](https://img.shields.io/badge/python-2.7,_3.6-blue.svg?style=plastic)](https://github.com/kilna/liquibase-docker/)

A lightweight Docker for running Liquibase.

* Docker: [liquibase](https://hub.docker.com/r/kilna/liquibase/)
* GitHub: [liquibase-docker](https://github.com/kilna/liquibase-docker)
* Based on [liquibase](https://www.liquibase.org)

# Liquibase Docker images with drivers

**Liquibase by itself cannot connect to a database.** To do actual database work, you will need a JDBC driver.

**You probably want one of these other images where I've bundled a database driver alongside Liquibase**:

| **liquibase-postgres** | [DockerHub](https://hub.docker.com/r/kilna/liquibase-postgres/) | [GitHub](https://github.com/kilna/liquibase-postgres-docker) |
|---|---|---|---|---|
| **liquibase-mysql** | [DockerHub](https://hub.docker.com/r/kilna/liquibase-mysql/) | [GitHub](https://github.com/kilna/liquibase-mysql-docker) |
| **liquibase-mariadb** | [DockerHub](https://hub.docker.com/r/kilna/liquibase-mariadb/) | [GitHub](https://github.com/kilna/liquibase-mariadb-docker) |
| **liquibase-sqlite** | [DockerHub](https://hub.docker.com/r/kilna/liquibase-sqlite/) | [GitHub](https://github.com/kilna/liquibase-sqlite-docker) |

# Usage

If you'd like to apply a changelog to a MySQL database, fire up a new container named _liquibase_:

```
$ docker run -e LIQUIBASE_HOST=database.server -e LIQUIBASE_USERNAME=user -e LIQUIBASE_PASSWORD=pass \
    -e LIQUIBASE_DATABASE=dbname --name liquibase -d kilna/liquibase-mysql
```

TO-DO: finish section

# Environment Variables and liquibase.properties

This docker image has a working Liquibase executable in the path, and an entrypoint which auto-generates a liquibase.properties file.

In order to create the liquibase.properties file, it uses the follow environment variables when the image is started with 'docker run':

* LIQUIBASE_HOST - host to connect to (default is 'db')
* LIQUIBASE_PORT - port to connect to (default is driver-specific)
* LIQUIBASE_USERNAME - username to connect as (default is 'liquibase')
* LIQUIBASE_PASSWORD - password for username (default is 'liquibase')
* LIQUIBASE_DATABASE - database name to connect to (default is 'liquibase')
* LIQUIBASE_CHANGELOG - changelog filename to use (default is 'changelog.xml')
* LIQUIBASE_LOGLEVEL - log level as defined by liquibase (default is 'info')
* LIQUIBASE_CLASSPATH - JDBC driver filename (driver-specific, typically /opt/jdbc/drivername-jdbc.jar)
* LIQUIBASE_DRIVER - JDBC object path (driver-specific)
* LIQUIBASE_URL - JDBC URL for connection (driver-specific)

The _liquibase.properties_ file is loaded into the default working dir _/workspace_ (which is also shared as a docker volume). The _/workspace/liquibase.properties_ file will have any variables substituted each time a 'docker run' command is performed...  so you can load your own _/workspace/liquibase.properties_ file and put `${HOST}` in it, and it will be replaced with the LIQUIBASE_HOST environment variable.

