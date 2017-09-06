FROM anapsix/alpine-java
LABEL maintainer="Kilna kilna@kilna.com"

ARG liquibase_version=3.5.3
ARG liquibase_download_url=https://github.com/liquibase/liquibase/releases/download/liquibase-parent-${liquibase_version}

ENV LIQUIBASE_DATABASE=${LIQUIBASE_DATABASE:-liquibase}\
    LIQUIBASE_USERNAME=${LIQUIBASE_USERNAME:-liquibase}\
    LIQUIBASE_PASSWORD=${LIQUIBASE_PASSWORD:-liquibase}\
    LIQUIBASE_HOST=${LIQUIBASE_HOST:-db}\
    LIQUIBASE_CHANGELOG=${LIQUIBASE_CHANGELOG:-changelog.xml}\
    LIQUIBASE_LOGLEVEL=${LIQUIBASE_LOGLEVEL:-info}

COPY entrypoint.sh /
RUN set -e -o pipefail;\
    chmod +x /entrypoint.sh;\
    apk --no-cache add curl ca-certificates;\ 
    tarfile=liquibase-${liquibase_version}-bin.tar.gz;\
    mkdir /opt/liquibase;\
    cd /opt/liquibase;\
    curl -SOLs ${liquibase_download_url}/${tarfile};\
    tar -xzf ${tarfile};\
    rm ${tarfile};\
    chmod +x liquibase;\
    ln -s /opt/liquibase/liquibase /usr/local/bin/liquibase;\
    mkdir /workspace /opt/jdbc;\
    set | grep -F LIQUIBASE_

COPY liquibase.properties /workspace/liquibase.properties
WORKDIR /workspace
ONBUILD VOLUME /workspace
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ['/bin/sh', '-i']
