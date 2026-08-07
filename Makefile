VERSION := $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux

format:
	gofmt -s -w ./

lint:
	golangci-lint run

test:
	go test -v


build: format
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${shell dpkg --print-architecture} go build -v -o kbot -ldflags "-X=github.com/visys-dev/kbot/cmd.appVersion=$(VERSION)"

clean:
	rm -rf kbot