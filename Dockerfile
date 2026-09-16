# Pin the base image to a specific minor tag for reproducible, cache-stable
# builds. `1.31-alpine` is what the floating `alpine` tag currently resolves to,
# so image contents are unchanged. Bump this line deliberately to pick up
# nginx/alpine security patches.
FROM nginx:1.31-alpine

# Copy the rarely-changing server config first so its layer stays cached when
# only the static assets change.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Static site assets change most often, so copy them last to maximize cache hits.
COPY www /www

EXPOSE 80

# The official nginx image already symlinks access.log -> /dev/stdout and
# error.log -> /dev/stderr, so logs reach the container stdout/stderr without a
# background `tail`. Use the image's default foreground command.
CMD ["nginx", "-g", "daemon off;"]
