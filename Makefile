# Regenerate Go stubs from the .proto contract.
#
# Requires `protoc` on PATH (apt install protobuf-compiler / brew install
# protobuf) — protoc-gen-go and protoc-gen-go-grpc are installed
# automatically by `make proto-tools` if missing.

MODULE      := github.com/nivekalara237/ci-bridge-plugin-sdk
PROTO_DIR   := proto
PROTO_FILES := $(shell find $(PROTO_DIR) -name '*.proto')

GOBIN := $(shell go env GOPATH)/bin
export PATH := $(GOBIN):$(PATH)

.PHONY: proto generate proto-tools proto-clean

## Generate Go + gRPC stubs from every .proto file under proto/
proto: proto-tools
	protoc --proto_path=$(PROTO_DIR) \
		--go_out=. --go_opt=module=$(MODULE) \
		--go-grpc_out=. --go-grpc_opt=module=$(MODULE) \
		$(PROTO_FILES)

## Alias matching the `go generate` naming convention
generate: proto

## Install protoc-gen-go / protoc-gen-go-grpc if not already on PATH.
## protoc itself is a separate binary and not installed here.
proto-tools:
	@command -v protoc >/dev/null 2>&1 || { \
		echo "protoc not found — install it first (apt install protobuf-compiler / brew install protobuf)"; \
		exit 1; \
	}
	@test -x "$(GOBIN)/protoc-gen-go" || go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	@test -x "$(GOBIN)/protoc-gen-go-grpc" || go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

## Remove generated stubs — useful to confirm `make proto` regenerates
## everything from scratch rather than relying on stale output.
proto-clean:
	find . -name '*.pb.go' -delete