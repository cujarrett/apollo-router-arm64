# Build the image locally. Emulated on a Mac, so expect an hour or more.
image:
    docker build --platform linux/arm64 -t apollo-router-arm64:dev .

# The version this repo currently builds
version:
    @sed -n 's/^ARG ROUTER_VERSION=//p' Dockerfile
