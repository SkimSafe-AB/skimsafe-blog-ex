# Multi-stage Dockerfile for Phoenix/Elixir application

# Stage 1: Build dependencies and application
FROM elixir:1.18 AS build

RUN apt-get update && apt-get install -y build-essential git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy mix files
COPY mix.exs mix.lock ./
RUN mix local.hex --force && \
    mix local.rebar --force

# Set production environment
ENV MIX_ENV=prod

# Get dependencies
RUN mix deps.get --only=prod
RUN mix deps.compile

# Copy source code
COPY config config/
COPY lib lib/
COPY priv priv/
COPY assets assets/
COPY rel rel/

# Install and build assets
RUN mix assets.setup
RUN mix assets.deploy

# Compile application and create release
RUN mix compile
RUN mix release

# Stage 2: Production runtime
FROM debian:bookworm-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libstdc++6 \
    openssl \
    libncurses6 \
    wget \
    locales \
    sqlite3 \
    libsqlite3-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Generate locale for UTF-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8

# Create non-root user
RUN groupadd -r elixir && useradd -r -g elixir elixir

WORKDIR /app

# Copy release from build stage
COPY --from=build --chown=elixir:elixir /app/_build/prod/rel/skimsafe_blogg ./

# Create directory for SQLite database
RUN mkdir -p /app/data && chown elixir:elixir /app/data

USER elixir

# Expose port
EXPOSE 4000

# Environment variables
ENV MIX_ENV=prod
ENV PORT=4000
ENV PHX_SERVER=true
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#   CMD wget --no-verbose --tries=1 --spider http://localhost:4000 || exit 1

# Start the application (with migrations)
CMD ["./bin/server"]
