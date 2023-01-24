# protoc

What's in the package:
- [protoc (github.com/protocolbuffers/protobuf)](https://github.com/protocolbuffers/protobuf)
  - [protoc-gen-go (google.golang.org/protobuf/cmd/protoc-gen-go)](https://github.com/protocolbuffers/protobuf-go/tree/master/cmd/protoc-gen-go)
  - [protoc-gen-go-grpc (google.golang.org/grpc/cmd/protoc-gen-go-grpc)](https://github.com/grpc/grpc-go/tree/master/cmd/protoc-gen-go-grpc)
  - [protoc-gen-grpc-web (github.com/grpc/grpc-web)](https://github.com/grpc/grpc-web)
  - [grpc-gateway](https://github.com/grpc-ecosystem/grpc-gateway) 
- [pbjs, pbts (npmjs.com/package/protobufjs)](https://www.npmjs.com/package/protobufjs)
- [ts-protoc-gen](https://github.com/improbable-eng/ts-protoc-gen)
- [buf](https://github.com/bufbuild/buf)

Mount your project directory into the container's `/mnt`

# TODO: https://github.com/nipunn1313/mypy-protobuf

- [ ] TODO: Better examples
- [ ] TODO: Multiple architectures
- [ ] TODO: Publish to GitHub's registries
- [ ] TODO: squash final image

Example usage:

```bash
docker run --rm -v $PWD:/mnt themakers/protoc:latest protoc --proto_path=proto-defs --go_out=. --go_opt=paths=source_relative proto-defs/my.proto
```

```go
//go:generate docker run --rm -v $PWD:/mnt themakers/protoc:latest protoc --proto_path=proto-defs --go_out=. --go_opt=paths=source_relative proto-defs/my.proto
```

