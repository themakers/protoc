################################################################
#### protoc container
FROM golang:1.18-buster as protoc

WORKDIR /protoc

####
####  protoc + protoc-gen-grpc-web
####

# https://github.com/protocolbuffers/protobuf/releases/
ARG PROTOC_VERSION=21.0-rc-2
ARG PROTOC_VERSION_GITHUB_RELEASE=v21.0-rc2

ARG PROTOC_GEN_GRPC_WEB_VERSION=1.3.1

RUN \
    apt-get update \
    && apt-get install -y \
        wget unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG PROTOC_VERSION

ARG PROTOC_ARCHIVE=protoc-${PROTOC_VERSION}-linux-x86_64.zip
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/${PROTOC_VERSION_GITHUB_RELEASE}/${PROTOC_ARCHIVE}
RUN unzip ${PROTOC_ARCHIVE} -d /protoc

# https://github.com/protocolbuffers/protobuf/releases/download/v21.0-rc-2/protoc-21.0-rc-2-linux-x86_64.zip
# https://github.com/protocolbuffers/protobuf/releases/download/v21.0-rc2/protoc-21.0-rc-2-linux-x86_64.zip

RUN rm ${PROTOC_ARCHIVE}

ARG PROTOC_GEN_GRPC_WEB_VERSION
RUN wget -O /protoc/bin/protoc-gen-grpc-web https://github.com/grpc/grpc-web/releases/download/${PROTOC_GEN_GRPC_WEB_VERSION}/protoc-gen-grpc-web-${PROTOC_GEN_GRPC_WEB_VERSION}-linux-x86_64
RUN chmod +x /protoc/bin/protoc-gen-grpc-web

####
####  golang tools
####

COPY / /protoc

RUN git clone https://github.com/googleapis/googleapis.git /protoc/googleapis

ENV GOBIN=/protoc/bin/
RUN go install \
        github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway \
        github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2 \
        google.golang.org/protobuf/cmd/protoc-gen-go \
        google.golang.org/grpc/cmd/protoc-gen-go-grpc \
        github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc \
        \
        github.com/bufbuild/buf/cmd/buf \
        github.com/bufbuild/buf/cmd/protoc-gen-buf-breaking \
        github.com/bufbuild/buf/cmd/protoc-gen-buf-lint



################################################################
#### Final container
FROM debian:buster

WORKDIR /protoc

COPY --from=protoc /protoc /protoc

RUN \
    apt-get update \
    && apt-get install -y curl tree \
    && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs mc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN npm install
RUN npm run install-hack

RUN chmod -R +x /protoc/bin

RUN ls -la /protoc/bin/

RUN \
    mv /protoc/bin/protoc /protoc/bin/protoc-original   &&\
    mv /protoc/bin/* /bin/   &&\
    mv /protoc/protoc /bin/   &&\
    ln -s /protoc/node_modules/.bin/protoc-gen-ts /bin/   &&\
    ln -s /protoc/node_modules/.bin/protoc-gen-ts_proto /bin/   &&\
    ln -s /protoc/pbjs /bin/pbjs   &&\
    ln -s /protoc/pbts /bin/pbts

RUN chmod -R 0777 /protoc

WORKDIR /mnt
