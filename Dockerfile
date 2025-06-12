FROM curlimages/curl:latest as build
RUN curl -L https://get.helm.sh/helm-v3.18.2-linux-amd64.tar.gz | tar -xzf - -C /tmp && mv /tmp/linux-amd64/helm /tmp && \
    chmod +x /tmp/helm
RUN curl -L https://github.com/helmfile/helmfile/releases/download/v1.1.1/helmfile_1.1.1_linux_amd64.tar.gz | tar -xzf - -C /tmp && \
    chmod +x /tmp/helmfile
RUN curl -L https://github.com/mikefarah/yq/releases/download/v4.45.4/yq_linux_amd64 --output /tmp/yq &&  \
    chmod +x /tmp/yq


FROM alpine:3.22.0

RUN apk add --no-cache bash

COPY --from=build /tmp/helm /usr/local/bin/_helm
COPY --from=build /tmp/helmfile /usr/local/bin/
COPY --from=build /tmp/yq /usr/local/bin/

COPY argocd-helmfile /usr/local/bin/
COPY plugin.yaml /home/argocd/cmp-server/config/plugin.yaml

ENV HOME="/home/argocd"
RUN chown -R 999:999 /home/argocd

USER 999
