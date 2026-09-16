# Pinned to a specific nginx minor on the smaller "alpine-slim" variant:
#  - "slim" drops modules this static site never uses (njs, geoip, image_filter,
#    xslt, ...), cutting the base image roughly in half.
#  - Pinning to 1.31 (vs the floating "alpine" tag) stops the base layer from
#    being invalidated every time Docker Hub republishes "alpine", while still
#    receiving 1.31.x patch updates.
FROM nginx:1.31-alpine-slim

# Copy the rarely-changing config first so that edits to www/ (the frequently
# changing content) don't invalidate the config layer.
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY www /www

EXPOSE 80

# No custom CMD: the base image's entrypoint already symlinks
# /var/log/nginx/{access,error}.log to stdout/stderr (so `qovery service logs`
# keeps working) and runs `nginx -g "daemon off;"` as PID 1. Keeping nginx as
# PID 1 means it receives SIGTERM directly on redeploy for a prompt, graceful
# shutdown -- the old `(tail -F ... &) && exec nginx` wrapper added a redundant
# process and is unnecessary.
