# Static site served by nginx — assets are copied as-is (no build/compile step).
#
# Base image: nginx:1.30-alpine-slim (nginx stable line, "slim" variant).
#   - "slim" drops perl/njs and modules this static site never uses:
#     ~5.5 MB vs ~25 MB for nginx:alpine (compressed) => ~78% smaller image
#     to push after every build and to pull on every deploy / scale-up.
#   - Pinning the minor version keeps BuildKit cache hits stable and builds
#     reproducible; the floating "alpine" tag silently changes underneath you.
#   - For a fully reproducible build, pin by digest instead (update on bumps):
#     FROM nginx:1.30-alpine-slim@sha256:32463212baf0e7d91aded2e9b843a4f2b9e017804b8c9d5bae7b51dcef64389c
FROM nginx:1.30-alpine-slim

# Config first: it changes far less often than the site content, so editing
# files under www/ no longer invalidates this cached layer.
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY www /www

EXPOSE 80

# No custom CMD needed. The official image's entrypoint already runs
# `nginx -g "daemon off;"` and symlinks the access/error logs to
# /dev/stdout and /dev/stderr, so Qovery/Kubernetes captures them.
# (The previous `tail -F /var/log/nginx/access.log` was redundant — that
# path is already a symlink to /dev/stdout.)
