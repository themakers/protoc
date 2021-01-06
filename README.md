# protoc

Example usage:

```bash
run --rm -v $PWD:/mnt themakers/protoc:latest --proto_path=proto-defs --go_out=. --go_opt=paths=source_relative proto-defs/my.proto
```

```go
//go:generate run --rm -v $PWD:/mnt themakers/protoc:latest --proto_path=proto-defs --go_out=. --go_opt=paths=source_relative proto-defs/my.proto
```
