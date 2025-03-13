ARG RUBY_VERSION=3.4.2

##############################
# Base Stage
##############################
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /app

# Install minimal runtime packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Set production environment variables
ENV RAILS_ENV=production \
    BUNDLE_PATH=/usr/local/bundle

##############################
# Build Stage
##############################
FROM base AS build

WORKDIR /app

# Install development tools required for building native extensions,
# including YAML headers (libyaml-dev) and pkg-config
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Copy Gemfile and Gemfile.lock from hello-app directory for dependency installation
COPY hello-app/Gemfile hello-app/Gemfile.lock ./

# Configure bundler and install gems without development and test groups
RUN bundle config set deployment true && \
    bundle config set without 'development test' && \
    bundle install

# Copy the rest of the Rails application from the hello-app folder
COPY hello-app/ .

##############################
# Final Stage
##############################
FROM base

WORKDIR /app

# Copy installed gems and application files from the build stage
COPY --from=build ${BUNDLE_PATH} ${BUNDLE_PATH}
COPY --from=build /app /app

# Expose port 3000 for Rails
EXPOSE 3000

# Start the Rails server bound to all interfaces
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
