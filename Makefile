APP := $(shell basename $(shell git remote get-url origin))
REGISTRY := gcr.io/stable-vista-418814
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux #linux darwin windows

TARGETOS := $(shell uname -s)

ifeq ($(TARGETOS),Linux)
    # Linux specific commands
    TARGETOS = linux
	TARGETARCH=$(shell dpkg --print-architecture)
endif
ifeq ($(TARGETOS),Darwin)
    # Mac OS X specific commands
    TARGETOS = Mac
	TARGETARCH=$(shell uname -m)
endif
ifeq ($(TARGETOS),FreeBSD)
    # FreeBSD specific commands
    TARGETOS = FREEBSD
endif
ifeq ($(TARGETOS),AIX)
    # AIX specific commands
    TARGETOS = AIX
endif
ifeq ($(TARGETOS),SunOS)
    # Solaris specific commands
    TARGETOS = SOLARIS
endif
ifeq ($(TARGETOS),Windows_NT)
    # Windows specific commands
    TARGETOS = Windows
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

