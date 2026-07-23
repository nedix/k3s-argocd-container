ARG ALPINE_VERSION=3.24.1
ARG ARGO_CD_VERSION=3.4.5
ARG HELM_VERSION=4.2.3
ARG K3S_VERSION=1.36.2
ARG KFILT_VERSION=1.0.0
ARG KUBECTL_VERSION=1.36.3
ARG KUSTOMIZE_VERSION=5.0.1
ARG S6_OVERLAY_VERSION=3.2.3.2

FROM ghcr.io/nedix/alpine-base-container:${ALPINE_VERSION} AS base

ARG S6_OVERLAY_VERSION

RUN apk add --virtual .build-deps \
        xz \
    && case "$(uname -m)" in \
        aarch64) \
            S6_OVERLAY_ARCHITECTURE="aarch64" \
        ;; arm*) \
            S6_OVERLAY_ARCHITECTURE="arm" \
        ;; x86_64) \
            S6_OVERLAY_ARCHITECTURE="x86_64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
    | tar -xpJf- -C / \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCHITECTURE}.tar.xz" \
    | tar -xpJf- -C / \
    && apk del .build-deps

FROM base AS build-base

WORKDIR /build/

RUN case "$(uname -m)" in \
        aarch64|arm*) \
            ARCHITECTURE="arm64" \
        ;; x86_64) \
            ARCHITECTURE="amd64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && echo "ARCHITECTURE=$ARCHITECTURE" >> .env

FROM build-base AS argo-cd

WORKDIR /build/argo-cd/

ARG ARGO_CD_VERSION

RUN . /build/.env \
    && wget -qo argocd "https://github.com/argoproj/argo-cd/releases/download/v${ARGO_CD_VERSION}/argocd-linux-${ARCHITECTURE}" \
    && chmod +x argocd

FROM build-base AS helm

WORKDIR /build/helm/

ARG HELM_VERSION

RUN . /build/.env \
    && wget -qO- "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCHITECTURE}.tar.gz" \
    | tar xzOf - linux-${ARCHITECTURE}/helm > helm \
    && chmod +x helm

FROM build-base AS kfilt

WORKDIR /build/kfilt/

ARG KFILT_VERSION

RUN . /build/.env \
    && wget -qo kfilt "https://github.com/ryane/kfilt/releases/download/v${KFILT_VERSION}/kfilt_linux_${ARCHITECTURE}"  \
    && chmod +x kfilt

FROM build-base AS kubectl

WORKDIR /build/kubectl/

ARG KUBECTL_VERSION

RUN . /build/.env \
    && wget -qO- "https://dl.k8s.io/v${KUBECTL_VERSION}/kubernetes-client-linux-${ARCHITECTURE}.tar.gz" \
    | tar xzOf - kubernetes/client/bin/kubectl > kubectl \
    && chmod +x kubectl

FROM build-base AS kustomize

WORKDIR /build/kustomize/

ARG KUSTOMIZE_VERSION

RUN . /build/.env \
    && wget -qO- "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCHITECTURE}.tar.gz" \
    | tar xzOf - kustomize > kustomize \
    && chmod +x kustomize

FROM base

COPY --link --from=argo-cd /build/argo-cd/argocd /usr/bin/argocd
COPY --link --from=helm /build/helm/helm /usr/bin/helm
COPY --link --from=kfilt /build/kfilt/kfilt /usr/bin/kfilt
COPY --link --from=kubectl /build/kubectl/kubectl /usr/bin/kubectl
COPY --link --from=kustomize /build/kustomize/kustomize /usr/bin/kustomize

COPY /rootfs/ /

ARG K3S_VERSION
ENV ENV="/etc/profile"
ENV K3S_VERSION="$K3S_VERSION"

RUN apk add \
        docker-cli \
        docker-engine \
        fuse3 \
        git-daemon

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK CMD kubectl get --raw="/readyz?verbose"

# Argo CD HTTP
EXPOSE 80

# ARGO CD HTTPS
EXPOSE 443

# Kubernetes API
EXPOSE 6443

VOLUME /var/lib/docker
VOLUME /var/lib/kubelet
