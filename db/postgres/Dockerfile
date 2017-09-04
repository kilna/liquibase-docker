FROM kilna/liquibase

ARG postgres_jdbc_version=42.1.4
ARG postgres_jdbc_download_url=https://jdbc.postgresql.org/download

RUN cd /opt/jdbc;\
    jarfile=postgresql-${postgres_jdbc_version}.jar;\
    curl -SOLs ${postgres_jdbc_download_url}/${jarfile};\
    ln -s ${jarfile} postgres-jdbc.jar

