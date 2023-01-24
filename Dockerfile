################################################################
#### protoc container
FROM golang:1.19-bullseye as protoc

ENV DEBIAN_FRONTEND noninteractive
ARG TARGETARCH

WORKDIR /protoc

####
####  protoc + protoc-gen-grpc-web
####

RUN \
    apt-get update \
    && apt-get install -y \
        wget unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# https://github.com/protocolbuffers/protobuf/releases/
ARG PROTOC_VERSION=21.12
ARG PROTOC_VERSION_GITHUB_RELEASE=v21.12

ARG PROTOC_GEN_GRPC_WEB_VERSION=1.4.2

ARG PROTOC_VERSION

RUN \
    case $TARGETARCH in \
      amd64) \
        export PROTOC_ARCH=x86_64 \
        ;; \
      arm64) \
        export PROTOC_ARCH=aarch_64 \
        ;; \
      *) \
        echo "Unsupported architecture >$TARGETARCH<" &&\
        exit 1 \
        ;; \
    esac &&\
    export PROTOC_ARCHIVE=protoc-${PROTOC_VERSION}-linux-${PROTOC_ARCH}.zip &&\
    wget https://github.com/protocolbuffers/protobuf/releases/download/${PROTOC_VERSION_GITHUB_RELEASE}/${PROTOC_ARCHIVE} &&\
    unzip ${PROTOC_ARCHIVE} -d /protoc &&\
    rm ${PROTOC_ARCHIVE}

# https://github.com/protocolbuffers/protobuf/releases/download/v21.0-rc-2/protoc-21.0-rc-2-linux-x86_64.zip
# https://github.com/protocolbuffers/protobuf/releases/download/v21.0-rc2/protoc-21.0-rc-2-linux-x86_64.zip

ARG PROTOC_GEN_GRPC_WEB_VERSION
RUN wget -O /protoc/bin/protoc-gen-grpc-web https://github.com/grpc/grpc-web/releases/download/${PROTOC_GEN_GRPC_WEB_VERSION}/protoc-gen-grpc-web-${PROTOC_GEN_GRPC_WEB_VERSION}-linux-x86_64
RUN chmod +x /protoc/bin/protoc-gen-grpc-web

####
####  golang tools
####

COPY / /protoc

RUN \
    git clone https://github.com/googleapis/googleapis.git --branch master --single-branch /protoc/googleapis &&\
    rm -rf /protoc/googleapis/.git

ENV GOBIN=/protoc/bin/
RUN go install \
        github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway \
        github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2 \
        google.golang.org/protobuf/cmd/protoc-gen-go \
        google.golang.org/grpc/cmd/protoc-gen-go-grpc \
        github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc \
        \
        github.com/bufbuild/buf/cmd/buf \
        github.com/bufbuild/connect-go/cmd/protoc-gen-connect-go \
        github.com/bufbuild/buf/cmd/protoc-gen-buf-breaking \
        github.com/bufbuild/buf/cmd/protoc-gen-buf-lint



################################################################
#### Final container
FROM debian:bullseye
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /protoc

COPY --from=protoc /protoc /protoc

RUN \
    apt-get update                       &&\
    apt-get install -y curl clang-format &&\
    curl -sL https://deb.nodesource.com/setup_16.x | bash - &&\
    apt-get install -y nodejs   &&\
    apt-get clean               &&\
    rm -rf /var/lib/apt/lists/* &&\
    \
    npm install          &&\
    npm run install-hack &&\
    \
    chmod -R +x /protoc/bin  &&\
    mv /protoc/bin/protoc /protoc/bin/protoc-original   &&\
    mv /protoc/bin/* /bin/    &&\
    mv /protoc/protoc /bin/   &&\
    ln -s /protoc/node_modules/.bin/protoc-gen-connect-web /bin/   &&\
    ln -s /protoc/node_modules/.bin/protoc-gen-es /bin/            &&\
    ln -s /protoc/node_modules/.bin/protoc-gen-ts /bin/            &&\
    ln -s /protoc/node_modules/.bin/protoc-gen-ts_proto /bin/      &&\
    ln -s /protoc/pbjs /bin/pbjs   &&\
    ln -s /protoc/pbts /bin/pbts   &&\
    \
    chmod -R 0777 /protoc

# https://superuser.com/questions/1409618/renaming-a-file-with-mv-cannot-move-to-a-subdirectory-of-itself

WORKDIR /mnt
