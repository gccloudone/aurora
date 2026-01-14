# Use Chainguard Go development image
FROM cgr.dev/chainguard/go:latest-dev

# Install tzdata for timezone support
RUN apk add --no-cache tzdata git wget tar && \
    wget https://github.com/gohugoio/hugo/releases/download/v0.145.0/hugo_extended_0.145.0_Linux-64bit.tar.gz && \
    tar -zxvf hugo_extended_0.145.0_Linux-64bit.tar.gz -C /usr/local/bin && \
    chmod +x /usr/local/bin/hugo && \
    rm hugo_extended_0.145.0_Linux-64bit.tar.gz

# Set the working directory inside the container
WORKDIR /src

# Copy the entire Hugo project into the container
COPY . .

# Build the Hugo site for use with the server
RUN hugo --minify

# Expose the default port used by the Hugo server (1313)
EXPOSE 1313

# Define the command to run the Hugo server in production mode
CMD ["hugo", "server", "--bind", "0.0.0.0", "--baseURL", "http://localhost", "--port", "1313", "--watch=false"]