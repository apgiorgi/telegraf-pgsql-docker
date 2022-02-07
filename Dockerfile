FROM golang:1.17.2-alpine AS build-env

# Install build dependencies
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh make

# Clone postgres branch
RUN git clone -b postgres https://github.com/phemmer/telegraf.git /go/src/github.com/influxdata/telegraf
WORKDIR /go/src/github.com/influxdata/telegraf

# Make static binary
RUN make deps
ENV LDFLAGS '-w -s'
ENV cgo '-nocgo'
ENV CGO_ENABLED 0
RUN make telegraf

# # Running environment. From golang to alpine, multi-stage build gives an image size 90%(~800MB) smaller. # TODO: try scratch to shave some extra MBs
FROM telegraf:1.20.4-alpine
COPY --from=build-env /go/src/github.com/influxdata/telegraf/cmd/telegraf /usr/local/bin/