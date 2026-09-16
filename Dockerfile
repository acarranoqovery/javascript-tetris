# Base image:
#  - `-slim` keeps only what's needed to run nginx and drops modules/packages a
#    static file server never uses (njs, geoip, image-filter, xslt, curl, ...).
#    Much smaller image => faster registry push after build and faster pull on
#    every deploy / scale-up / node change.
#  - Pinned to the `1.30` minor tag: still receives patch updates, but the digest
#    is stable between them. The old floating `alpine` tag rotated its digest on
#    every nginx release, busting the build cache and making builds non-reproducible.
FROM nginx:1.30-alpine-slim

# Copy the rarely-changing server config first so that edits to the site content
# below do not invalidate this layer (and vice-versa) => better layer caching.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Static site assets.
COPY www /www

EXPOSE 80

# No custom CMD on purpose: inherit the base image's entrypoint
# (`/docker-entrypoint.sh`) and default command (`nginx -g "daemon off;"`).
# The official nginx image already symlinks access.log -> /dev/stdout and
# error.log -> /dev/stderr, so logs stream to the container (and to Qovery)
# without the previous `tail -F /var/log/nginx/access.log &` background hack.
# Inheriting the default command also lets nginx receive SIGTERM/SIGQUIT
# directly for a graceful shutdown (pairs with Qovery's pre-stop grace period).
