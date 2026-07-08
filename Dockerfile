# Use the official slim Ruby image to keep the footprint small
FROM ruby:3.4-slim

# Install system dependencies: build tools, ImageMagick, and ExifTool
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    imagemagick \
    libvips \
    exiftool \
    pandoc \
    git \
    && rm -rf /lib/apt/lists/*

# Set up the working directory inside the container
WORKDIR /app

# Copy dependency files first to utilize Docker caching layers
COPY Gemfile Gemfile.lock ./

# Install bundler and project gem dependencies
RUN gem install bundler && bundle install

# Copy the rest of the application code into the container
COPY . .

# Default command launches the Rake tasks dashboard helper
CMD ["bundle", "exec", "rake", "-T"]
