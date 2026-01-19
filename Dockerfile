# Hugo build stage
FROM hugomods/hugo:exts-0.145.0 AS hugo-builder

# Set the working directory
WORKDIR /site

# Copy the project files into the container
COPY . /site

# Ensure the proper ownership for the /site directory to avoid permission issues
# Assuming the Hugo image uses user id 1000
RUN chown -R 1000:1000 /site

# Build the Hugo site to the /site/public directory
RUN hugo --destination /site/public

# NGINX stage
FROM nginx:alpine

# Create necessary directories and ensure permissions for NGINX user (default user is "101")
RUN mkdir -p /var/cache/nginx && \
    mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/cache/nginx/proxy_temp && \
    mkdir -p /var/cache/nginx/fastcgi_temp && \
    mkdir -p /var/cache/nginx/uwsgi_temp && \
    mkdir -p /var/cache/nginx/scgi_temp && \
    chown -R 101:101 /var/cache/nginx

# Set the default NGINX user explicitly (user 101 is NGINX's default non-root user in this image)
USER 101

# Copy NGINX configuration file (make sure the config does not specify privileged ports, like 80)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built Hugo site from the builder stage
COPY --from=hugo-builder /site/public /usr/share/nginx/html

# Set the working directory to /usr/share/nginx/html
WORKDIR /usr/share/nginx/html

# Expose a non-privileged port (e.g., 8080 instead of 80) as NGINX runs as a non-root user
EXPOSE 8080

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
