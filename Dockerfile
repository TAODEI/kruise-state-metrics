FROM golang:1.16 as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

# Copy the go source
COPY main.go main.go
COPY internal/ internal/ 
COPY pkg/ pkg/

# Build
ENV GOPROXY=https://goproxy.cn

RUN GO111MODULE=on go build -a -o kruise-state-metrics main.go

# Use Ubuntu 20.04 LTS as base image to package the manager binary
FROM ubuntu:focal
# This is required by daemon connnecting with cri
RUN ln -s /usr/bin/* /usr/sbin/ && apt-get update -y \
  && apt-get install --no-install-recommends -y ca-certificates \
  && apt-get clean && rm -rf /var/log/*log /var/lib/apt/lists/* /var/log/apt/* /var/lib/dpkg/*-old /var/cache/debconf/*-old
WORKDIR /
COPY --from=builder /workspace/kruise-state-metrics .
ENTRYPOINT ["/kruise-state-metrics"]