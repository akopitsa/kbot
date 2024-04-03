# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM golang:1.16 as builder

# Copy local code to the container image.
WORKDIR /app
COPY . .

# Build the command inside the container.
RUN make ${TARGETOS}

# Use a Docker multi-stage build to create a lean production image.
# https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
FROM alpine:3.14
RUN apk add --no-cache ca-certificates

# Copy the binary to the production image from the builder stage.
COPY --from=builder /app/kbot /kbot

# Run the web service on container startup.
CMD ["/kbot"]