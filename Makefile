APP := $(notdir $(CURDIR))
REGISTRY ?= quay.io/visystemhub
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null)
IMAGE_TAG ?= $(REGISTRY)/$(APP):$(VERSION)
LDFLAGS := -X=github.com/visys-dev/kbot/cmd.appVersion=$(VERSION)

.PHONY: format lint test get build linux arm macos macOS windows image clean

format:
	gofmt -s -w ./

lint:
	golangci-lint run

test:
	go test -v ./...

get:
	go mod download

GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
OUTPUT ?= kbot-$(GOOS)-$(GOARCH)$(if $(filter windows,$(GOOS)),.exe)

build: get
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -v \
		-o $(OUTPUT) -ldflags "$(LDFLAGS)" .

linux:
	$(MAKE) build GOOS=linux GOARCH=amd64

arm:
	$(MAKE) build GOOS=linux GOARCH=arm64

macos:
	$(MAKE) build GOOS=darwin GOARCH=arm64

macOS: macos

windows:
	$(MAKE) build GOOS=windows GOARCH=amd64

image:
	docker build --build-arg VERSION=$(VERSION) -t $(IMAGE_TAG) .

clean:
	rm -f kbot-linux-amd64 kbot-linux-arm64 kbot-darwin-arm64 kbot-windows-amd64.exe
	-docker rmi $(IMAGE_TAG)
