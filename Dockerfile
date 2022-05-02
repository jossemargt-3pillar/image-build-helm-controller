ARG BCI_IMAGE=registry.suse.com/bci/bci-base:latest
ARG GO_IMAGE=rancher/hardened-build-base:v1.16.12b7

FROM ${BCI_IMAGE} as bci

FROM ${GO_IMAGE} as builder
ARG TAG="" 
RUN apk add --no-cache ca-certificates git

RUN git clone --depth=1 https://github.com/rancher/helm-controller.git
RUN cd /go/helm-controller                                           && \
    git fetch --all --tags --prune                                   && \
    git checkout tags/${TAG} -b ${TAG}                               && \
    mkdir bin                                                        && \
    [ "$(uname)" != "Darwin" ] && LINKFLAGS="-extldflags -static -s" && \
    CGO_ENABLED=1 go build -v -ldflags "-X main.VERSION=$VERSION $LINKFLAGS" -o bin/helm-controller

FROM bci
RUN zypper update -y && \ 
    zypper clean --all

COPY --from=builder /go/helm-controller/bin /usr/local/bin

