# syntax=docker/dockerfile:1
#
# CoLab — PRODUCTION target image for the security (pentest) environment.
# ----------------------------------------------------------------------------
# This image is the *system under test* for the FERPA compliance engagement.
# It reproduces a real Heroku build of CoLab as closely as practical so that
# the penetration test exercises production behaviour (eager-loaded code,
# precompiled+fingerprinted assets, static file serving, jemalloc), rather
# than the development server.
#
# Buildpack parity:
#   * heroku-26 stack      -> heroku/heroku:26-build   (Ubuntu 26.04)
#                             https://devcenter.heroku.com/articles/heroku-26-stack
#   * Ruby buildpack       -> Ruby pinned via the repo's mise.toml
#   * Node.js buildpack    -> Node + Yarn pinned via the repo's mise.toml
#   * jemalloc buildpack   -> github.com/gaffneyc/heroku-buildpack-jemalloc
#                             (jemalloc 5.3.0, vendored to /app/vendor/jemalloc,
#                              enabled at runtime via LD_PRELOAD)
#
# The build context is the repository root (see buildContainers.* / compose).
# ----------------------------------------------------------------------------

# heroku-26 *build* image: includes the compilers and -dev headers needed to
# build native gems (mysql2, nokogiri, ...) and to compile jemalloc from source.
FROM heroku/heroku:26-build

# Heroku slugs are assembled in /app and run as the unprivileged `heroku` user.
ENV APP_HOME=/app
WORKDIR ${APP_HOME}

# ---------------------------------------------------------------------------
# jemalloc — reproduce gaffneyc/heroku-buildpack-jemalloc exactly.
# The buildpack compiles ONLY the shared libraries, installs them under
# --prefix=/app/vendor/jemalloc, and drops a .profile.d hook that exports
# LD_PRELOAD when JEMALLOC_ENABLED=true.  Version + SHA256 are taken verbatim
# from the buildpack's checksum table so behaviour matches production.
# ---------------------------------------------------------------------------
ARG JEMALLOC_VERSION=5.3.0
ARG JEMALLOC_SHA256=2db82d1e7119df3e71b7640219b6dfe84789bc0537983c3b7ac4f7189aecfeaa
RUN set -eux; \
    cd /tmp; \
    curl -fsSL -o jemalloc.tar.bz2 \
      "https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2"; \
    echo "${JEMALLOC_SHA256}  jemalloc.tar.bz2" | sha256sum -c -; \
    mkdir -p /tmp/jemalloc-src; \
    tar --strip-components=1 -xjf jemalloc.tar.bz2 -C /tmp/jemalloc-src; \
    cd /tmp/jemalloc-src; \
    ./configure --prefix=/app/vendor/jemalloc; \
    make -j "$(nproc)" build_lib_shared; \
    make BINDIR=/app/vendor/jemalloc/bin LIBDIR=/app/vendor/jemalloc/lib install_bin install_lib_shared; \
    rm -rf /tmp/jemalloc*

# The buildpack's .profile.d/jemalloc.sh hook, reproduced verbatim.
RUN mkdir -p /app/.profile.d && \
    printf '%s\n' \
      'export PATH="$PATH:/app/vendor/jemalloc/bin"' \
      '' \
      '# Configure LD_PRELOAD when JEMALLOC_ENABLED is set to "true".' \
      "if [ \"\$JEMALLOC_ENABLED\" = 'true' ]; then" \
      '  export LD_PRELOAD="/app/vendor/jemalloc/lib/libjemalloc.so $LD_PRELOAD"' \
      'fi' \
      > /app/.profile.d/jemalloc.sh

# ---------------------------------------------------------------------------
# Native libraries — build-time and runtime — that the heroku-26 base does not
# ship by default:
#   * libssl-dev / pkg-config -> build Ruby against the SYSTEM OpenSSL.
#   * ruby-vips -> libvips (vips.so.42), required at boot (Bundler.require).
#   * image / PDF handling   -> imagemagick + poppler/glib (best-effort).
# We deliberately do NOT vendor a separate OpenSSL for Ruby: a vendored libssl
# shadows the system one and then conflicts with system libs (libcurl, pulled
# in by libvips) that require the system OpenSSL's symbol versions
# (e.g. OPENSSL_3.2.0). Building Ruby against the system OpenSSL keeps a single,
# consistent libssl.so.3 in the process.
# (heroku-26's default user is the non-root `heroku`, so switch to root for apt.)
# ---------------------------------------------------------------------------
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends libssl-dev pkg-config imagemagick && \
    ( apt-get install -y --no-install-recommends libvips42t64 \
      || apt-get install -y --no-install-recommends libvips42 \
      || apt-get install -y --no-install-recommends libvips ) && \
    ( apt-get install -y --no-install-recommends libpoppler-glib8 libglib2.0-0t64 \
      || apt-get install -y --no-install-recommends libpoppler-glib8 libglib2.0-0 \
      || true ) && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Toolchain (mise) — pin Ruby/Node/Yarn to the exact versions in mise.toml,
# matching what the Ruby & Node.js buildpacks would resolve.
# ---------------------------------------------------------------------------
RUN chown -R heroku:heroku /app
USER heroku
ENV HOME=/home/heroku
RUN curl -fsSL https://mise.jdx.dev/install.sh | sh
ENV PATH="/app/node_modules/.bin:/home/heroku/.local/share/mise/shims:/home/heroku/.local/bin:/app/vendor/jemalloc/bin:${PATH}"

# Copy only the version manifest first so the toolchain layer caches well.
COPY --chown=heroku:heroku mise.toml ${APP_HOME}/mise.toml
RUN mise trust ${APP_HOME}/mise.toml && \
    mise settings add idiomatic_version_file_enable_tools ruby && \
    mise install ruby node yarn

# ---------------------------------------------------------------------------
# Gems — production groups only (drops development/test tooling, shrinking the
# attack surface to what really ships to prod).
# ---------------------------------------------------------------------------
COPY --chown=heroku:heroku Gemfile Gemfile.lock ${APP_HOME}/
RUN mise exec -- bundle config set --local without 'development test' && \
    mise exec -- bundle config set --local deployment true && \
    mise exec -- bundle install --jobs "$(nproc)" --retry 3

# ---------------------------------------------------------------------------
# JavaScript dependencies (Yarn 4, immutable install).
# ---------------------------------------------------------------------------
COPY --chown=heroku:heroku package.json yarn.lock .yarnrc.yml ${APP_HOME}/
COPY --chown=heroku:heroku .yarn ${APP_HOME}/.yarn
RUN mise exec -- yarn install --immutable

# ---------------------------------------------------------------------------
# Application source + asset precompile (the Rails "assets" buildpack step).
# A .dockerignore keeps host node_modules/log/tmp out of the context; we still
# purge defensively before building Linux-native assets.
# SECRET_KEY_BASE_DUMMY lets Rails boot for precompile without a real secret.
# Precompile is best-effort: if the JS feed/toolchain is unavailable at build
# time the entrypoint rebuilds assets on first boot.
# ---------------------------------------------------------------------------
COPY --chown=heroku:heroku . ${APP_HOME}
RUN rm -rf ${APP_HOME}/log/* ${APP_HOME}/tmp/* 2>/dev/null || true
RUN RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 \
      mise exec -- bundle exec rails assets:precompile \
    || echo "WARN: assets:precompile failed at build time; entrypoint will retry on boot."

# ---------------------------------------------------------------------------
# Production runtime configuration.  Secrets (SECRET_KEY_BASE / RAILS_MASTER_KEY
# / COLAB_DATABASE_PASSWORD / DATABASE_URL) are injected at run time via compose
# — never baked into the image.  jemalloc is enabled per the buildpack's
# recommended MALLOC_CONF for Rails.
# ---------------------------------------------------------------------------
ENV RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    JEMALLOC_ENABLED=true \
    MALLOC_CONF=dirty_decay_ms:1000,narenas:2,background_thread:true \
    PORT=3000

COPY --chown=heroku:heroku containers/colab_prod_entrypoint.sh /app/bin/colab_prod_entrypoint.sh
RUN chmod +x /app/bin/colab_prod_entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/app/bin/colab_prod_entrypoint.sh"]
CMD ["web"]
