export ROOT=$(realpath $(dir $(firstword $(MAKEFILE_LIST))))
export BIN=$(ROOT)/bin
export GOBIN?=$(BIN)
export GO=$(shell which go)
export CGO_ENABLED=1
export PROTO_OUT=$(ROOT)
export GOX=$(BIN)/gox

$(eval GIT_COMMIT=$(shell git rev-parse --short HEAD))
$(eval BRANCH_NAME=$(shell git rev-parse --abbrev-ref HEAD))
$(eval COMPILED_BY=$(shell hostname))

export GO_LDFLAGS="-X main.CompiledBy=${COMPILED_BY} -X main.Version=${GIT_COMMIT} -X main.BranchName=${BRANCH_NAME} -X main.BuildTime=`date -u '+%Y-%m-%d_%I:%M:%S%p'`"

all:
	@$(GO) build -ldflags ${GO_LDFLAGS} -o bin/utg .

proto:
		@protoc \
			-Iprotofiles \
			--go_out=${PROTO_OUT} \
			--go-grpc_out=${PROTO_OUT} \
			protofiles/*.proto
.PHONY: proto

install-gox:
	@$(GO) install github.com/mitchellh/gox@v1.0.1

.PHONY: build-linux
build-linux: install-gox
	@$(GOX) -ldflags ${GO_LDFLAGS} --arch=amd64 --os=linux --output="dist/utg_{{.OS}}_{{.Arch}}"
	@$(GOX) -ldflags ${GO_LDFLAGS} --arch=arm --os=linux --output="dist/utg_{{.OS}}_{{.Arch}}"

.PHONY: build-macOS
build-macOS: install-gox
	@$(GOX) -ldflags ${GO_LDFLAGS} --arch=amd64 --os=darwin --output="dist/utg_{{.OS}}_{{.Arch}}"

.PHONY: build-windows
build-windows: install-gox
	@$(GOX) -ldflags ${GO_LDFLAGS} --arch=amd64 --os=windows --output="dist/utg_{{.OS}}_{{.Arch}}"

.PHONY: build-artifacts
build-artifacts:
	@$(MAKE) build-linux && \
		$(MAKE) build-macOS && \
		$(MAKE) build-windows

cert:
	@openssl genrsa -out cert/ca.key 2048
	@openssl req -new -x509 -days 365 -key cert/ca.key -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=Acme Root CA" -out cert/ca.crt
	@openssl req -newkey rsa:2048 -nodes -keyout cert/server.key -subj "/C=CN/ST=GD/L=SZ/O=Acme, Inc./CN=*.mrjosh.net" -out cert/server.csr
	@openssl x509 -req -extfile <(printf "subjectAltName=DNS:mrjosh.net,DNS:*.mrjosh.net") -days 365 -in cert/server.csr -CA cert/ca.crt -CAkey cert/ca.key -CAcreateserial -out cert/server.crt
