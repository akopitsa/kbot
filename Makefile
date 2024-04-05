APP := $(shell basename $(shell git remote get-url origin))
REGISTRY := quay.io/projectquay
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux #linux darwin windows
TARGETARCH= := $(dpkg --print-architecture) #amd64 arm64

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/den-vasyliev/kbot/cmd.appVersion=${VERSION}

linux:
	make build TARGETOS=linux TARGETARCH=${TARGETARCH}

mac:
	make build TARGETOS=darwin TARGETARCH=$(uname -m)

windows:
	make build TARGETOS=windows TARGETARCH=amd64

arm:
	make build TARGETOS=linux TARGETARCH=arm64

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}  --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

