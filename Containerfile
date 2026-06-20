FROM scratch AS ctx
COPY build_files /build_files

FROM quay.io/fedora/fedora-bootc:44

COPY rootfiles/sshd/* /etc/ssh/sshd_config.d/
COPY rootfiles/firewalld/* /usr/lib/firewalld/zones/

COPY quadlets/pasarguard /etc/containers/systemd/users/1000

RUN --mount=type=bind,from=ctx,source=/build_files,target=/ctx \
    --mount=type=cache,target=/var/cache \
    /ctx/build && \
    /ctx/cleanup && \
    /ctx/finalize

RUN bootc container lint --no-truncate
