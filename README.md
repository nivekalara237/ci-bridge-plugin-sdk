# ci-bridge-plugin-sdk

[![CI](https://github.com/nivekalara237/ci-bridge-plugin-sdk/actions/workflows/ci.yml/badge.svg)](https://github.com/nivekalara237/ci-bridge-plugin-sdk/actions/workflows/ci.yml)
[![Go Reference](https://pkg.go.dev/badge/github.com/nivekalara237/ci-bridge-plugin-sdk.svg)](https://pkg.go.dev/github.com/nivekalara237/ci-bridge-plugin-sdk)

The shared plugin contract for [sonarbridge-go](https://github.com/nivekalara237/sonarbridge-go)'s VCS plugin architecture: a small [HashiCorp go-plugin](https://github.com/hashicorp/go-plugin) + gRPC handshake that both the host and every provider plugin (GitLab, GitHub, Bitbucket, ...) import — and only this.

## Why this exists

`sonarbridge-go` loads VCS providers as **separate plugin processes** instead of compiling every provider's SDK into one binary. For that to work without coupling every plugin to the whole sonarbridge-go codebase, the host and the plugins need to agree on exactly one thing: the wire contract. That contract — the proto messages, the generated gRPC stubs, and the go-plugin wiring to serve/consume them — lives here, and nowhere else.

```
                    ci-bridge-plugin-sdk
                    (this module: the contract)
                            │
              ┌─────────────X─────────────┐
              │                           │
        sonarbridge-go              bridge-vcs-gitlab
        (the host)                      (a plugin, its own repo, its own go.mod, its own release cycle)
                                    bridge-vcs-gitea
                                    bridge-vcs-bitbucket
```

Neither side depends on the other. Both depend on this.

## Install

```bash
go get github.com/nivekalara237/ci-bridge-plugin-sdk
```

## What's inside

| Package                           | What it's for                                                                                  |
|-----------------------------------|------------------------------------------------------------------------------------------------|
| `pluginv1`                        | Generated protobuf/gRPC stubs for the `PluginInfo` handshake service                           |
| `pluginshared`                    | The go-plugin wiring both sides need: `Handshake` config and the `PluginInfoGRPCPlugin` bridge |
| `capability`                      | Well-known capability string constants (`repository`, `pull_request`, `webhook`, ...)          |
| `proto/plugin/v1/handshake.proto` | The source `.proto` — read this first if `pluginv1` alone doesn't answer your question         |

## Usage

### On the plugin side (a VCS provider binary)

This is the whole job of a plugin binary: implement `PluginInfoServer`, wrap it in `pluginshared.Map`, and hand it to `plugin.Serve`.

```go
package main

import (
	"context"

	goplugin "github.com/hashicorp/go-plugin"

	"github.com/nivekalara237/ci-bridge-plugin-sdk/capability"
	"github.com/nivekalara237/ci-bridge-plugin-sdk/pluginshared"
	pluginv1 "github.com/nivekalara237/ci-bridge-plugin-sdk/plugin/v1"
)

type gitlabServer struct {
	pluginv1.UnimplementedPluginInfoServer
}

func (s *gitlabServer) GetInfo(ctx context.Context, req *pluginv1.GetInfoRequest) (*pluginv1.InfoResponse, error) {
	return &pluginv1.InfoResponse{
		Name:            "gitlab",
		Version:         "0.1.0",
		PluginType:      "vcs",
		ProtocolVersion: 1,
		Capabilities:    []string{capability.Repository, capability.PullRequest, capability.Webhook},
	}, nil
}

func main() {
	goplugin.Serve(&goplugin.ServeConfig{
		HandshakeConfig: pluginshared.Handshake,
		Plugins:         pluginshared.Map(&gitlabServer{}),
		GRPCServer:      goplugin.DefaultGRPCServer,
	})
}
```

### On the host side (sonarbridge-go, or anything else that wants to launch these plugins)

The host never builds `pluginshared.Map` with a real implementation — `Impl` stays `nil`, since only `GRPCClient` is ever called there.

```go
client := goplugin.NewClient(&goplugin.ClientConfig{
	HandshakeConfig:  pluginshared.Handshake,
	Plugins:          pluginshared.Map(nil),
	Cmd:              exec.Command(pathToPluginBinary),
	AllowedProtocols: []goplugin.Protocol{goplugin.ProtocolGRPC},
	AutoMTLS:         true,
})

rpcClient, err := client.Client()
raw, err := rpcClient.Dispense(pluginshared.PluginKey)
info := raw.(pluginv1.PluginInfoClient)

resp, err := info.GetInfo(ctx, &pluginv1.GetInfoRequest{})
// resp.Name, resp.Capabilities, ...
```

sonarbridge-go's own `internal/plugin/runtime.GoPluginAdapter` is a complete, tested reference implementation of this side if you want the full picture (retry/backoff, crash detection, graceful stop).

## Regenerating the protobuf stubs

Needs `protoc`, `protoc-gen-go` and `protoc-gen-go-grpc` on your `PATH`:

```shell
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

protoc --proto_path=proto \
       --go_out=. --go_opt=module=github.com/nivekalara237/ci-bridge-plugin-sdk \
       --go-grpc_out=. --go-grpc_opt=module=github.com/nivekalara237/ci-bridge-plugin-sdk \
       proto/plugin/v1/handshake.proto
```

## Versioning

Two version numbers matter here, and they're deliberately independent:

- **The module's own semver tag** (`v1.2.3`, via `go get github.com/nivekalara237/ci-bridge-plugin-sdk@v1.2.3`) — bump this for any change to this repo, following normal Go module semver rules (a breaking change to exported API needs a `/v2` major version bump).
- **`InfoResponse.protocol_version`** (currently `1`) — the *business* protocol version a plugin declares at handshake, independent of this module's own version. A host can depend on an old `ci-bridge-plugin-sdk` release while still talking to a plugin declaring a newer `protocol_version`, as long as the host's own compatibility check accepts it. Don't conflate the two.

## About the `replace` directives in `go.mod`

`go.mod` redirects `google.golang.org/grpc`, `google.golang.org/protobuf`, `golang.org/x/*` and a few others to their canonical GitHub mirrors instead of resolving them through their vanity import path. This was originally worked around a restricted sandbox that couldn't reach `golang.org`/`google.golang.org`, but it's harmless anywhere: those mirrors *are* the real upstream source (grpc-go and protobuf-go are developed on GitHub; the `google.golang.org/...` paths are just aliases). On a machine with normal internet access you can safely leave them as-is, or run `go get -u ./... && go mod tidy` to pick up newer versions if a vanity path resolves cleanly for you.

## Development

```bash
go build ./...
go test ./...
gofmt -l .   # should print nothing
go vet ./...
```

No test files yet — this module is pure wiring with no branching logic of its own; it's exercised end-to-end by sonarbridge-go's integration tests (real subprocess, real gRPC, real crash detection).

## License

Not yet chosen — add a `LICENSE` file (MIT/Apache-2.0 are the usual defaults for a Go module) before making this repository public.
