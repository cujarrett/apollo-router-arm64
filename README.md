# apollo-router-arm64

Apollo's official router image crashes on a Raspberry Pi 5 the moment it starts:

```
<jemalloc>: Unsupported system page size
```

A page is the unit a kernel hands out memory in. Nearly every Linux machine uses 4K pages. The Pi 5's kernel uses 16K, which is faster on its CPU, and Raspberry Pi OS ships that kernel by default.

The router uses jemalloc for memory allocation. jemalloc bakes the page size in at compile time, and Apollo compiles for 4K. On a 16K kernel it refuses to start.

The Pi also ships a 4K kernel, but it has a smaller address space, and Envoy's allocator refuses that instead. So no kernel on the Pi runs both the router and the Istio sidecar.

This repo fixes the router side. It builds the same source at the same tag with `JEMALLOC_SYS_WITH_LG_PAGE=16`, which makes jemalloc accept pages up to 64K. Nothing else changes. The runtime stage mirrors upstream's Dockerfile, so the Apollo operator swaps it in through `deployment.podTemplate.image`.

Upstream has had the fix open since 2023, in [router#3382](https://github.com/apollographql/router/issues/3382).

Image: `ghcr.io/cujarrett/apollo-router-arm64:<version>`, signed with cosign by digest.

## Upgrading

Renovate opens a PR seven days after Apollo tags a release, bumping `ROUTER_VERSION` in the Dockerfile. The PR builds the image without pushing, so a version that does not compile never merges. Minor and patch versions merge themselves on green. A major waits for a person. On merge, CI builds, pushes and signs.

Cloud arm64, such as AWS Graviton, runs 4K pages. This is never needed there.
