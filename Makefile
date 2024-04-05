APP := $(shell basename $(shell git remote get-url origin))
REGISTRY := quay.io/projectquay
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux #linux darwin windows

TARGETARCH := $(shell uname -s)

ifeq ($(TARGETARCH),Linux)
    # Linux specific commands
    TARGETARCH = LINUX
endif
ifeq ($(TARGETARCH),Darwin)
    # Mac OS X specific commands
    TARGETARCH = MAC
endif
ifeq ($(TARGETARCH),FreeBSD)
    # FreeBSD specific commands
    TARGETARCH = FREEBSD
endif
ifeq ($(TARGETARCH),AIX)
    # AIX specific commands
    TARGETARCH = AIX
endif
ifeq ($(TARGETARCH),SunOS)
    # Solaris specific commands
    TARGETARCH = SOLARIS
endif
ifeq ($(TARGETARCH),Windows_NT)
    # Windows specific commands
    TARGETARCH = WINDOWS
endif

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/akopitsa/kbot/cmd.appVersion=${VERSION}

linux:
	make build TARGETOS=linux TARGETARCH=$(shell dpkg --print-architecture)

mac:
	make build TARGETOS=darwin TARGETARCH=$(shell uname -m)

windows:
	make build TARGETOS=windows TARGETARCH=amd64

arm:
	make build TARGETOS=linux TARGETARCH=$(shell uname -m)

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}  --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

