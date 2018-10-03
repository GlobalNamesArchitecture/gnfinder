# gnfinder

Ruby gem to access functionality of [gnfinder] project written in Go

## Development

### Requirements

This gem uses gRPC to access [gnfinder] server. gRPC in turn depends on a
protobuf library. If you need to compile Ruby programs with protobuf you need to install [Go] language and download [gnfinder] project.

```bash
go get github.com/gnames/gnfinder
```

Then you need to run bundle from the root of the project and run:

```bash
rake grpc
```

[gnfinder]: https://github.com/gnames/gnfinder
[Go]: https://golang.org/doc/install
