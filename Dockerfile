FROM anapsix/alpine-java

ARG liquibase_version=3.5.3
ARG liquibase_download_url=https://github.com/liquibase/liquibase/releases/download/liquibase-parent-${liquibase_version}

SHELL [ "/bin/bash", "-e", "-o", "pipefail", "-c" ]

RUN apk --update add curl ca-certificates;\ 
    tarfile=liquibase-${liquibase_version}-bin.tar.gz;\
    mkdir /opt/liquibase;\
    cd /opt/liquibase;\
    curl -SOLs ${liquibase_download_url}/${tarfile};\
    tar -xzf ${tarfile};\
    rm ${tarfile};\
    chmod +x liquibase;\
    ln -s /opt/liquibase/liquibase /usr/local/bin/liquibase;\
    mkdir /workspace /opt/jdbc

WORKDIR /workspace
ONBUILD COPY . /workspace
ONBUILD RUN [[ -d test ]] && mv test /opt/liquibase_test
ONBUILD VOLUME /workspace

