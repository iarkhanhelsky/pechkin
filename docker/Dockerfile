# Multi-stage Dockerfile for Pechkin
# Stage 1: Build the gem and install dependencies
FROM ruby:3.3-alpine AS builder

WORKDIR /build

# Install build dependencies
RUN apk add --no-cache build-base

# Copy gemspec and required files for building
COPY lib/pechkin/version.rb lib/pechkin/version.rb
COPY pechkin.gemspec .
COPY lib/ lib/
COPY bin/ bin/

# Build the gem
RUN gem build pechkin.gemspec

# Install the gem (this compiles native extensions)
RUN gem install *.gem --no-document

# Stage 2: Final runtime image
FROM ruby:3.3-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    bash \
    tzdata \
    wget

# Create pechkin user and directories
RUN addgroup -S pechkin && adduser -S pechkin -G pechkin && \
    mkdir -p /var/data/pechkin && \
    chown -R pechkin:pechkin /var/data/pechkin

WORKDIR /app

# Copy installed gems from builder stage (includes binaries)
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set environment variables
ENV PECHKIN_CONFIG_DIR=/var/data/pechkin
ENV PECHKIN_PORT=9292
ENV PECHKIN_BIND_ADDRESS=0.0.0.0
ENV PECHKIN_MIN_THREADS=5
ENV PECHKIN_MAX_THREADS=20

# Expose HTTP port
EXPOSE 9292

# Switch to non-root user
USER pechkin

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
