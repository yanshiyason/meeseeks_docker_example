# The version of Alpine to use for the final image
# This should match the version of Alpine that the `elixir:1.10.3-alpine` image uses
ARG ALPINE_VERSION=3.11

FROM elixir:1.10.3-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base git python \
        ca-certificates \
        gcc

# setup rust env -- START
# NOTE when RUSTFLAGS is not set, building meeseeks fails with musl error.
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.43.1 \
    RUSTFLAGS="-C target-feature=-crt-static"

RUN set -eux; \
    url="https://static.rust-lang.org/rustup/archive/1.21.1/x86_64-unknown-linux-musl/rustup-init"; \
    wget "$url"; \
    echo "0c86d467982bdf5c4b8d844bf8c3f7fc602cc4ac30b29262b8941d6d8b363d7e *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;
# setup rust env -- END

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./

RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY lib lib

RUN mix do compile, release

# prepare release image
FROM alpine:${ALPINE_VERSION} AS app

RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/meeseeks_docker_example ./

ENV HOME=/app

CMD ["bin/meeseeks_docker_example", "start"]
