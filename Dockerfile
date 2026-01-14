# Use Chainguard Go development image for dependencies
FROM cgr.dev/chainguard/go:latest-dev

# Install tzdata, Hugo dependencies, and Hugo Extended binary
RUN apk add --no-cache tzdata git && \
    wget https://github.com/gohugoio/hugo/releases/download/v0.145.0/hugo_extended_0.145.0_Linux-64bit.tar.gz && \
    tar -zxvf hugo_extended_0.145.0_Linux-64bit.tar.gz -C /usr/local/bin && \
    chmod +x /usr/local/bin/hugo && \
    rm -f hugo_extended_0.145.0_Linux-64bit.tar.gz && \
    hugo version

# Set the working directory inside the container
WORKDIR /src

# Ensure write permissions for the non-root user to avoid permission issues
RUN chown -R 1000:1000 /src

# Copy the Hugo project files into the container
COPY . .

# Build the Hugo site
RUN hugo --minify

# Expose the Hugo default server port (1313)
EXPOSE 1313

# SET ENTRYPOINT explicitly to Hugo binary
ENTRYPOINT ["/usr/local/bin/hugo"]

# Define default CMD arguments for Hugo (these will be passed to ENTRYPOINT)
CMD ["server", "--bind", "0.0.0.0", "--port", "1313", "--baseURL", "http://localhost", "--watch=false", "--noBuildLock", "--disableBuildStats"]