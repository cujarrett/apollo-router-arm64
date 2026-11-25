# Apollo's router image aborts on a Raspberry Pi 5, whose kernel uses 16K pages.
# jemalloc is compiled for 4K. Same source, same version, one build flag.
# renovate: datasource=github-releases depName=apollographql/router
ARG ROUTER_VERSION=2.19.1

FROM rust:1.100.0-slim-bookworm@sha256:bb875b0f8ce726053e259034848c471840e96bfe591fd52556178ae9a05e6126 AS build
ARG ROUTER_VERSION
# libprotobuf-dev holds google/protobuf/*.proto, which reports.proto imports.
# Debian ships protoc without them.
RUN apt-get update && apt-get install -y --no-install-recommends \
      git build-essential protobuf-compiler libprotobuf-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN rustup component add rustfmt
WORKDIR /usr/src
RUN git clone --depth 1 --branch "v${ROUTER_VERSION}" https://github.com/apollographql/router.git router
WORKDIR /usr/src/router
# lg_page 16 means pages up to 64K, so the binary runs on 4K and 16K kernels alike.
ENV JEMALLOC_SYS_WITH_LG_PAGE=16
RUN cargo build --locked --release -p apollo-router
RUN mkdir -p /dist/config /dist/schema \
    && mv target/release/router /dist/ \
    && cp dockerfiles/router.yaml /dist/config/

# Runtime stage mirrors dockerfiles/Dockerfile.router upstream, so the Apollo operator
# can swap this in for the official image with no other change.
FROM debian:bookworm-slim@sha256:e67eeead736ff7bbe258ef088bff683635c561b1fcfefad0806c1df4ab49ce0e
ARG ROUTER_VERSION
RUN useradd -m router \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /dist
COPY --from=build --chown=root:root /dist /dist
ENV APOLLO_ROUTER_CONFIG_PATH="/dist/config/router.yaml"
LABEL org.opencontainers.image.source="https://github.com/cujarrett/apollo-router-arm64"
LABEL org.opencontainers.image.version="${ROUTER_VERSION}"
USER router
ENTRYPOINT ["/dist/router"]
