ARG UBI_IMAGE=registry.access.redhat.com/ubi7/ubi-minimal:latest
ARG GO_IMAGE=rancher/build-base:v1.14.2

FROM ${UBI_IMAGE} as ubi

FROM ${GO_IMAGE} as builder
ARG TAG="" 
RUN apt update     && \ 
    apt upgrade -y && \ 
    apt install -y ca-certificates git

RUN git clone --depth=1 https://github.com/rancher/helm-controller.git
RUN cd /go/helm-controller                                                                          && \
    git fetch --all --tags --prune                                                                  && \
    git checkout tags/${TAG} -b ${TAG}                                                              && \
    mkdir bin                                                                                       && \
    [ "$(uname)" != "Darwin" ] && LINKFLAGS="-extldflags -static -s"                                && \
    CGO_ENABLED=1 go build -v -ldflags "-X main.VERSION=$VERSION $LINKFLAGS" -o bin/helm-controller

FROM ubi
RUN microdnf update -y && \ 
    rm -rf /var/cache/yum

COPY --from=builder /go/helm-controller/bin /usr/local/bin

