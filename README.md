# protoc

Mount your project directory into the container's `/mnt`

- [ ] TODO: squash final image

Example usage:

```bash
docker run --rm -v $PWD:/mnt themakers/protoc:latest protoc --proto_path=proto-defs --go_out=. --go_opt=paths=source_relative proto-defs/my.proto
```

```go
//go:generate docker run --rm -v $PWD:/mnt themakers/protoc:latest protoc --proto_path=proto-defs --go_out=. --go_opt=paths=source_relative proto-defs/my.proto
```
