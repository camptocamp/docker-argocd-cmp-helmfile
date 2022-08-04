FROM curlimages/curl:latest as helm-dowloader
RUN curl -L https://get.helm.sh/helm-v3.9.2-linux-amd64.tar.gz | tar -xzf - -C /tmp && mv /tmp/linux-amd64/helm /tmp && \
    chmod +x /tmp/helm

FROM curlimages/curl:latest as helm-sops-dowloader
RUN curl -L https://github.com/camptocamp/helm-sops/releases/download/20220419-3/helm-sops_20220419-3_linux_amd64.tar.gz | tar -xzf - -C /tmp && \
    chmod +x /tmp/helm-sops

FROM curlimages/curl:latest as helmfile-dowloader
RUN curl -L https://github.com/roboll/helmfile/releases/download/v0.144.0/helmfile_linux_amd64 --output /tmp/helmfile && \
    chmod +x /tmp/helmfile

FROM curlimages/curl:latest as yq-dowloader
RUN curl -L https://github.com/mikefarah/yq/releases/download/v4.25.1/yq_linux_amd64 --output /tmp/yq &&  \
    chmod +x /tmp/yq


FROM alpine:3.16.1

COPY --from=helm-dowloader /tmp/helm /usr/local/bin/_helm
COPY --from=helm-sops-dowloader /tmp/helm-sops /usr/local/bin/helm
COPY --from=helmfile-dowloader /tmp/helmfile /usr/local/bin/
COPY --from=yq-dowloader /tmp/yq /usr/local/bin/

COPY argocd-helmfile /usr/local/bin/
COPY plugin.yaml /home/argocd/cmp-server/config/plugin.yaml

USER 999
