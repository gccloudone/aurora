FROM klakegg/hugo:ext-alpine

RUN apk add git && \
  git config --global --add safe.directory /src

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