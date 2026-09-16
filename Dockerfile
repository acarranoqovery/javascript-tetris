# nginx:alpine-slim drops the Perl/njs/geoip/xslt/image_filter modules that a
# static file server never uses, making the image meaningfully smaller than
# nginx:alpine (a drop-in for `try_files`-based static serving).
FROM nginx:alpine-slim

# Copy the rarely-changed server config first so its layer stays cached
# across content-only changes; copy the static content last.
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY www /www

EXPOSE 80

# No custom CMD needed: the official nginx image already streams access/error
# logs to stdout/stderr and runs `nginx -g "daemon off;"` as PID 1 via its
# entrypoint, so SIGTERM reaches nginx directly for clean, fast pod shutdown.
# (The previous `tail -F /var/log/nginx/access.log` was a no-op — that path is
# already a symlink to /dev/stdout.)
