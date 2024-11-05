################################################################
#### protoc container
FROM golang:1.23-alpine AS go

ENV CGO_ENABLED=0
RUN \
  go install github.com/bufbuild/buf/cmd/buf@latest  &&\
  go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest  &&\
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest  &&\
  go install connectrpc.com/connect/cmd/protoc-gen-connect-go@latest


################################################################
#### Final container
FROM node:lts-alpine AS final

WORKDIR /protoc

COPY --from=go /go/bin /usr/local/bin

RUN \
   npm install -g @connectrpc/protoc-gen-connect-es@"^1.0.0" @bufbuild/protoc-gen-es@"^1.0.0"

WORKDIR /mnt
