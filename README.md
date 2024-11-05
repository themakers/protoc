# protoc


## Usage example

#### **generate.sh**
```bash
docker run \
  --rm -i \
  -u "$(id -u):$(id -g)" \                  # To match the rights of the generated files with the rights of your user
  -e USER="$USER" \
  -v /etc/passwd:/etc/passwd:ro \           # To make container's user name match your system user name 
  -v "$PWD:$PWD":rw \                       # Mount current directory
  -v "$HOME/.cache:$HOME/.cache":rw \       # Mount ~/.cache directory (required by the `buf` tool)
  --workdir "$PWD" \                        # Current working directory
  docker.io/themakers/protoc:v1.0.11 \
  /bin/bash <<- "EOF"

  # Format .proto files using clang 
  find ./protocol -type f -name "*.proto" | xargs clang-format -i

  protoc \
    -I /protoc/include \
    --proto_path=protocol \
    \
    --connect-web_opt=target=ts,ts_nocheck=false \
    --es_opt=target=ts,ts_nocheck=false \
    \
    --connect-web_out=src/protocol \
    --es_out=src/protocol \
    \
    $(find ./protocol -type f -name '*.proto'  |  sed -e 's/^\.\/protocol\///')

EOF
```
#### **.clang-format**
```clang
---
UseTab: Never
BasedOnStyle: Google
---
Language: Proto
AlignConsecutiveDeclarations: true
AlignConsecutiveAssignments: true
ReflowComments: true
ColumnLimit: 140
```



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

