FROM golang:1.13 AS build-env

# Install dep
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

# Clone postgres branch
RUN git clone -b postgres https://github.com/svenklemm/telegraf.git /go/src/github.com/influxdata/telegraf
WORKDIR /go/src/github.com/influxdata/telegraf

# Make static binary
RUN make deps
RUN make static

# Running environment. From golang to alpine, multi-stage build gives an image size 90%(~800MB) smaller. Use scratch to shave some extra MBs
FROM alpine:3.11
COPY --from=build-env /go/src/github.com/influxdata/telegraf/telegraf /usr/local/bin/

EXPOSE 8125/udp 8092/udp 8094

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["telegraf"]