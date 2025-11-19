FROM --platform=$BUILDPLATFORM docker.io/curlimages/curl:latest as helm-dowloader
ARG TARGETARCH
RUN curl -L https://get.helm.sh/helm-v4.0.0-linux-$TARGETARCH.tar.gz | tar -xzf - -C /tmp && mv /tmp/linux-$TARGETARCH/helm /tmp && \
    chmod +x /tmp/helm

FROM --platform=$BUILDPLATFORM docker.io/curlimages/curl:latest as helm-sops-dowloader
ARG TARGETARCH
RUN curl -L https://github.com/camptocamp/helm-sops/releases/download/20250929-1/helm-sops_20250929-1_linux_$TARGETARCH.tar.gz | tar -xzf - -C /tmp && \
    chmod +x /tmp/helm-sops

FROM --platform=$BUILDPLATFORM docker.io/curlimages/curl:latest as helmfile-dowloader
ARG TARGETARCH
RUN curl -L https://github.com/helmfile/helmfile/releases/download/v1.2.0/helmfile_1.2.0_linux_$TARGETARCH.tar.gz | tar -xzf - -C /tmp && \
    chmod +x /tmp/helmfile

FROM --platform=$BUILDPLATFORM docker.io/curlimages/curl:latest as yq-dowloader
ARG TARGETARCH
RUN curl -L https://github.com/mikefarah/yq/releases/download/v4.48.2/yq_linux_$TARGETARCH --output /tmp/yq &&  \
    chmod +x /tmp/yq


FROM docker.io/alpine:3.22.2

RUN apk add --no-cache bash

COPY --from=helm-dowloader /tmp/helm /usr/local/bin/_helm
COPY --from=helm-sops-dowloader /tmp/helm-sops /usr/local/bin/helm
COPY --from=helmfile-dowloader /tmp/helmfile /usr/local/bin/
COPY --from=yq-dowloader /tmp/yq /usr/local/bin/

COPY argocd-helmfile /usr/local/bin/
COPY plugin.yaml /home/argocd/cmp-server/config/plugin.yaml

ENV HOME="/home/argocd"
RUN chown -R 999:999 /home/argocd

USER 999
