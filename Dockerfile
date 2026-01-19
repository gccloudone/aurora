FROM hugomods/hugo:exts-0.145.0

# Set the working directory
WORKDIR /site

# Copy the project files into the container
COPY . /site

# Ensure the proper ownership for the /site directory to avoid permission issues
# Assuming the Hugo image uses user id 1000
RUN chown -R 1000:1000 /site

# Default command to run Hugo server
CMD ["server", "--bind", "0.0.0.0", "--environment", "production"]
