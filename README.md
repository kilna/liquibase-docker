# liquibase-docker

[![](https://images.microbadger.com/badges/image/kilna/liquibase.svg)](https://microbadger.com/images/kilna/liquibase)
[![](https://img.shields.io/docker/pulls/kilna/liquibase.svg?style=plastic)](https://hub.docker.com/r/kilna/liquibase/)
[![](https://img.shields.io/docker/stars/kilna/liquibase.svg?style=plastic)](https://hub.docker.com/r/kilna/liquibase/)
[![](https://img.shields.io/badge/docker_build-automated-blue.svg?style=plastic)](https://cloud.docker.com/swarm/kilna/repository/docker/kilna/liquibase/builds)

**A lightweight Docker for running [Liquibase](https://www.liquibase.org)**

DockerHub: [liquibase](https://hub.docker.com/r/kilna/liquibase/) - GitHub: [liquibase-docker](https://github.com/kilna/liquibase-docker)

# Liquibase Docker images with drivers

**Liquibase by itself cannot connect to a database.** To do actual database work, you will need a [JDBC driver](https://en.wikipedia.org/wiki/JDBC_driver).

**⚠ You probably want one of these other Docker images where I've bundled a database driver alongside Liquibase ⚠**

| DockerHub Image | GitHub Source |
|---|---|
| [**liquibase-postgres**](https://hub.docker.com/r/kilna/liquibase-postgres/) | [liquibase-postgres-docker](https://github.com/kilna/liquibase-postgres-docker) |
| [**liquibase-mysql**](https://hub.docker.com/r/kilna/liquibase-mysql/) | [liquibase-mysql-docker](https://github.com/kilna/liquibase-mysql-docker) |
| [**liquibase-mariadb**](https://hub.docker.com/r/kilna/liquibase-mariadb/) | [liquibase-mariadb-docker](https://github.com/kilna/liquibase-mariadb-docker) |
| [**liquibase-sqlite**](https://hub.docker.com/r/kilna/liquibase-sqlite/) | [liquibase-sqlite-docker](https://github.com/kilna/liquibase-sqlite-docker) |

# Usage

## Using your own derived Dockerfile

You can use this image by creating your own `Dockerfile` which inherits using a FROM line:

```
FROM kilna/liquibase-mysql-docker
ENV LIQUIBASE_HOST=database.server
ENV LIQUIBASE_DATABASE=dbname
ENV LIQUIBASE_USERNAME=user
ENV LIQUIBASE_PASSWORD=pass
COPY changelog.xml /workspace
```

Make sure to create an appropriate [changelog.xml](http://www.liquibase.org/documentation/xml_format.html) in the same directory as your Dockerfile.

Then you can build your derived Dockerfile to an image tagged 'changelog-image':

```
$ docker build --tag changelog-image .
```

Any time you make changes to the example project, you'll need to re-run the `docker build` command above, or you can using docker volumes as described below to sync local filesystem changes into the container. To run liquibase using the new image you can:

```
$ docker run changelog-image liquibase updateTestingRollback
```

Since the working directory within the container is /workspace, and since the entrypoint generates a a liquibase.properties file using the provided environment variables, it will know to look for _changelog.xml_ by default and apply the change.  See the environment variables below to change this behavior.

## Using the image directly with a mounted docker volume

If you'd like to apply a changelog to a MySQL database without deriving your own container, run the contiainer
appropriate to your database like so... where _/local/path/to/changelog/_ is the directory where a valid [changelog.xml](http://www.liquibase.org/documentation/xml_format.html) exists:

```
$ docker run -e LIQUIBASE_HOST=database.server -e LIQUIBASE_USERNAME=user -e LIQUIBASE_PASSWORD=pass \
    -e LIQUIBASE_DATABASE=dbname -v /local/path/to/changelog/:/workspace/ kilna/liquibase-mysql \
    liquibase updateTestingRollback
```

# Environment Variables and liquibase.properties

This docker image has a working Liquibase executable in the path, and an entrypoint which auto-generates a [liquibase.properties](http://www.liquibase.org/documentation/liquibase.properties.html) file.

In order to create the liquibase.properties file, it uses the follow environment variables when the image is started with 'docker run':

| Environment Variable | Purpose | Default |
|----------------------|---------|---------|
| LIQUIBASE_HOST       | Database host to connect to* | db |
| LIQUIBASE_PORT       | Database port to connect to* | _driver-specific integer <br> example: 3306 for MySQL/MariaDB_ |
| LIQUIBASE_DATABASE   | Database name to connect to† | liquibase |
| LIQUIBASE_USERNAME   | Username to connect to database as* | liquibase |
| LIQUIBASE_PASSWORD   | Password for username* | liquibase |
| LIQUIBASE_CHANGELOG  | Default changelog filename to use | changelog.xml |
| LIQUIBASE_LOGLEVEL   | Log level as defined by Liquibase <br> _Valid values: debug, info, warning, severe, off_ | info |
| LIQUIBASE_CLASSPATH  | JDBC driver filename | _driver-specific <br> example: /opt/jdbc/mysql-jdbc.jar_ |
| LIQUIBASE_DRIVER     | JDBC object path | _driver-specific <br> example: org.mariadb.jdbc.Driver_ |
| LIQUIBASE_URL        | JDBC URL for connection | _driver-specific <br> example: jdbc:mariadb://${HOST}:${PORT}/${DATABASE}_ |
| LIQUIBASE_DEBUG      | If set to 'yes', when _docker run_ is executed, will show the values of all LIQUIBASE_* environment variables and describes any substitutions performed on _liquibase.properties_ | _unset_ |

_* Not applicable to file-based databases (SQLite) - † Used as the filename for file-based databases (SQLite)_

The generated _liquibase.properties_ file is loaded into the default working dir _/workspace_ (which is also shared as a docker volume). The _/workspace/liquibase.properties_ file will have any variables substituted each time a 'docker run' command is performed...  so you can load your own _/workspace/liquibase.properties_ file and put `${HOST}` in it, and it will be replaced with the LIQUIBASE_HOST environment variable.

If you want to see what the contents of the generated _liquibase.properties_ file are, you can:

```
$ docker run image-name cat liquibase.properties
```
