FROM kilna/liquibase

ARG sqlite_jdbc_version=3.20.0
ARG sqlite_jdbc_download_url=https://bitbucket.org/xerial/sqlite-jdbc/downloads

RUN cd /opt/jdbc;\
    jarfile=sqlite-jdbc-${sqlite_jdbc_version}.jar;\
    curl -SOLs ${sqlite_jdbc_download_url}/${jarfile};\
    ln -s ${jarfile} sqlite-jdbc.jar

