# Pin the exact nginx:alpine image (the current `alpine` multi-arch index digest) so
# every build reuses the same cached base layer instead of re-resolving a moving tag,
# and so the build is reproducible. This is byte-for-byte the image already deployed.
# Bump this digest deliberately (e.g. via Renovate/Dependabot) to pick up patched
# nginx/alpine releases.
FROM nginx:alpine@sha256:62ff2089abf5a9ed33bd232895bef5e22f7bb4b200675cec49a5ebc48e3d4ac8

# The server config changes rarely, so copy it before the site assets: a content-only
# change then invalidates just the layer below and this layer stays cached.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Static site assets change most often -> keep them as the last COPY / last cache layer.
COPY www /www

EXPOSE 80

# nginx:alpine already symlinks access.log -> /dev/stdout and error.log -> /dev/stderr,
# so the previous `(tail -F ... &)` sidecar process was redundant. The exec form makes
# nginx PID 1 so it receives SIGTERM directly for a fast, clean shutdown during rollouts.
CMD ["nginx", "-g", "daemon off;"]
