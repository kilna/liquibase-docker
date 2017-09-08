# liquibase-docker/test

This directory contains a test to ensure liquibase works correctly within the container by installing and using the SQLite driver.

At build-time this directory is copies into /opt/test_liquibase, and to validate the built image, DockerHub runs the [run_test.sh](./run_test.sh) script automatically via docker-compose.test.yml.

