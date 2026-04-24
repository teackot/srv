registry := env("BUILD_REGISTRY", "localhost")
image := env("BUILD_IMAGE", "srv")

branch := env("BUILD_BRANCH", "44")
tag := env("BUILD_TAG", branch)

base := env("BUILD_BASE", "quay.io/fedora/fedora-bootc:" + branch)

build_suffix := env("BUILD_BUILD_SUFFIX", "-build")

pull:
    sudo podman pull {{base}}
    sudo podman pull {{registry}}/{{image}}:{{tag}} || true

build *ARGS:
    sudo buildah bud \
        --layers=true \
        {{ARGS}} \
        -t "{{registry}}/{{image}}:{{tag}}{{build_suffix}}" \
        "."

rechunk *ARGS:
    sudo podman run --rm --privileged -v /var/lib/containers:/var/lib/containers {{ARGS}} \
        {{base}} \
        /usr/libexec/bootc-base-imagectl rechunk \
        {{registry}}/{{image}}:{{tag}}{{build_suffix}} \
        {{registry}}/{{image}}:{{tag}}
