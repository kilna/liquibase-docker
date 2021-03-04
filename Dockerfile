FROM anapsix/alpine-java:8

ARG liquibase_version=4.3.1
ARG liquibase_download_url=https://github.com/liquibase/liquibase/releases/download/v${liquibase_version}

ENV LIQUIBASE_DATABASE=${LIQUIBASE_DATABASE:-liquibase}\
    LIQUIBASE_USERNAME=${LIQUIBASE_USERNAME:-liquibase}\
    LIQUIBASE_PASSWORD=${LIQUIBASE_PASSWORD:-liquibase}\
    LIQUIBASE_HOST=${LIQUIBASE_HOST:-db}\
    LIQUIBASE_CHANGELOG=${LIQUIBASE_CHANGELOG:-changelog.xml}\
    LIQUIBASE_LOGLEVEL=${LIQUIBASE_LOGLEVEL:-info}

COPY bin/* /usr/local/bin/
COPY test/ /opt/test_liquibase/
RUN set -e -o pipefail;\
    chmod +x /usr/local/bin/* /opt/test_liquibase/run_test.sh;\
    apk --no-cache add curl ca-certificates;\ 
    tarfile=liquibase-${liquibase_version}.tar.gz;\
    mkdir /opt/liquibase;\
    cd /opt/liquibase;\
    curl -SOLs ${liquibase_download_url}/${tarfile};\
    tar -xzf ${tarfile};\
    rm ${tarfile};\
    chmod +x liquibase;\
    ln -s /opt/liquibase/liquibase /usr/local/bin/liquibase;\
    mkdir /workspace /opt/jdbc

COPY liquibase.properties /workspace/liquibase.properties
WORKDIR /workspace
ONBUILD VOLUME /workspace
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD ['/bin/sh', '-i']
