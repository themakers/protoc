ARG PROTOC_VERSION=3.14.0
ARG PROTOC_GEN_GO_VERSION=1.25.0


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


################################################################
#### golang plugin container
FROM golang:buster as protoc-go

WORKDIR /protoc

RUN go mod init example.com/mod

ARG PROTOC_GEN_GO_VERSION

RUN go get -v -d google.golang.org/protobuf/cmd/protoc-gen-go@v${PROTOC_GEN_GO_VERSION}

RUN go build -x -o /protoc/protoc-gen-go google.golang.org/protobuf/cmd/protoc-gen-go


################################################################
#### Merge container
FROM debian:buster as merge


COPY --from=protoc /protoc /protoc
COPY --from=protoc-go /protoc/protoc-gen-go /protoc/bin/protoc-gen-go
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
    ln -s /protoc/protoc /bin/protoc \
    && ln -s /protoc/pbjs /bin/pbjs \
    && ln -s /protoc/pbts /bin/pbts

RUN npm run install-hack

WORKDIR /mnt

#ENTRYPOINT [ "/protoc/protoc" ]
#CMD [ "--help" ]
