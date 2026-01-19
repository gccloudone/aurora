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

# Use the official NGINX image
FROM nginx:alpine

# Ensure required directories exist and fix permissions for non-root NGINX user
RUN mkdir -p /var/cache/nginx/client_temp && \
    mkdir -p /var/cache/nginx/proxy_temp && \
    mkdir -p /var/cache/nginx/fastcgi_temp && \
    chown -R 101:101 /var/cache/nginx

# Copy NGINX configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built Hugo site from the builder stage
COPY --from=hugo-builder /site/public /usr/share/nginx/html

# Expose port 80 for HTTP traffic
EXPOSE 8080

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
