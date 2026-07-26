ARG CHUNKAH_CONFIG_STR

FROM scratch AS ctx
COPY build_files /build_files

FROM quay.io/fedora/fedora-bootc:44 as builder

COPY cosign.pub /etc/pki/containers/srv.pub
COPY --chmod=644 rootfiles/signing/policy.json /etc/containers/policy.json
COPY --chmod=644 rootfiles/signing/srv.yaml /etc/containers/registries.d/srv.yaml

COPY rootfiles/sshd/* /etc/ssh/sshd_config.d/
COPY rootfiles/firewalld/* /usr/lib/firewalld/zones/

COPY quadlets/pasarguard /etc/containers/systemd/users/1000

RUN --mount=type=bind,from=ctx,source=/build_files,target=/ctx \
    --mount=type=cache,target=/var/cache \
    /ctx/build && \
    /ctx/cleanup && \
    /ctx/finalize

RUN bootc container lint --no-truncate

FROM quay.io/coreos/chunkah AS chunkah
ARG CHUNKAH_CONFIG_STR
RUN --mount=from=builder,src=/,target=/chunkah,ro \
    --mount=type=bind,target=/run/src,rw \
    chunkah build \
        --prune /sysroot/ \
        --label ostree.commit- \
        --label ostree.final-diffid- \
        --max-layers=256 \
        --output oci:/run/src/out

FROM oci:out
