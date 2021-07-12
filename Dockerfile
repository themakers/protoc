# https://github.com/protocolbuffers/protobuf/releases/
ARG PROTOC_VERSION=3.17.3

# https://github.com/protocolbuffers/protobuf-go/tags
ARG PROTOC_GEN_GO_VERSION=1.27.1

# https://github.com/grpc/grpc-go/tags
ARG PROTOC_GRPC_VERSION=1.39.0

#
ARG PROTOC_GEN_GO_GRPC_VERSION=1.1.0

# https://github.com/grpc/grpc-web/releases
ARG PROTOC_GEN_GRPC_WEB_VERSION=1.2.1

# https://github.com/protobufjs/protobuf.js/tags

################################################################
#### protoc container
FROM debian:buster as protoc

WORKDIR /protoc

RUN \
    apt-get update \
    && apt-get install -y \
        wget unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG PROTOC_VERSION
ARG PROTOC_ARCHIVE=protoc-${PROTOC_VERSION}-linux-x86_64.zip

RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/${PROTOC_ARCHIVE}

RUN unzip ${PROTOC_ARCHIVE} -d /protoc

RUN rm ${PROTOC_ARCHIVE}

ARG PROTOC_GEN_GRPC_WEB_VERSION
RUN wget -O /protoc/bin/protoc-gen-grpc-web https://github.com/grpc/grpc-web/releases/download/${PROTOC_GEN_GRPC_WEB_VERSION}/protoc-gen-grpc-web-${PROTOC_GEN_GRPC_WEB_VERSION}-linux-x86_64
RUN chmod +x /protoc/bin/protoc-gen-grpc-web

################################################################
#### golang plugin container
FROM golang:buster as protoc-go

WORKDIR /protoc

RUN go mod init example.com/mod

ARG PROTOC_GEN_GO_VERSION
ARG PROTOC_GEN_GO_GRPC_VERSION

RUN go get -v -d google.golang.org/protobuf/cmd/protoc-gen-go@v${PROTOC_GEN_GO_VERSION}

RUN go build -x -o /protoc/protoc-gen-go google.golang.org/protobuf/cmd/protoc-gen-go

#RUN go get -v -d google.golang.org/grpc@v${PROTOC_GRPC_VERSION}

RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v${PROTOC_GEN_GO_GRPC_VERSION}


################################################################
#### Merge container
FROM debian:buster as merge

COPY --from=protoc /protoc /protoc
COPY --from=protoc-go /protoc/protoc-gen-go /protoc/bin/protoc-gen-go
COPY --from=protoc-go /go/bin/protoc-gen-go-grpc /protoc/bin/protoc-gen-go-grpc
COPY / /protoc


################################################################
#### Final container
FROM debian:buster

WORKDIR /protoc

COPY --from=merge /protoc /protoc
RUN \
    apt-get update \
    && apt-get install -y curl tree \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN npm install

RUN \
    ln -s /protoc/protoc /bin/protoc && \
    ln -s /protoc/bin/protoc-gen-go-grpc /bin/protoc-gen-go-grpc && \
    ln -s /protoc/protoc-gen-go /bin/protoc-gen-go && \
    ln -s /protoc/pbjs /bin/pbjs && \
    ln -s /protoc/pbts /bin/pbts

RUN chmod -R 0777 /protoc

RUN npm run install-hack

WORKDIR /mnt

#ENTRYPOINT [ "/protoc/protoc" ]
#CMD [ "--help" ]
