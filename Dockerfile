FROM scratch AS git_debs
ARG RELEASE_TAG
ARG GIT_DEB
ARG GIT_DEB_SHA256
ARG GIT_MAN_DEB
ARG GIT_MAN_DEB_SHA256
ADD --checksum=sha256:${GIT_DEB_SHA256} https://github.com/k0pernikus/git-debian-latest/releases/download/${RELEASE_TAG}/${GIT_DEB} /
ADD --checksum=sha256:${GIT_MAN_DEB_SHA256} https://github.com/k0pernikus/git-debian-latest/releases/download/${RELEASE_TAG}/${GIT_MAN_DEB} /

FROM debian:trixie-slim
ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_VERSION
LABEL org.opencontainers.image.source="https://github.com/k0pernikus/git-debian-latest"
RUN --mount=type=bind,from=git_debs,target=/git-debs \
    apt-get update \
    && apt-get install --yes /git-debs/*.deb \
    && rm --recursive --force /var/lib/apt/lists/*
RUN --mount=type=bind,source=scripts/assert-git-version,target=/usr/local/bin/assert-git-version \
    assert-git-version "$GIT_VERSION"
