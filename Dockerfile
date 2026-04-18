FROM ghcr.io/cloudnative-pg/postgresql:17.6-minimal-trixie AS builder

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git ca-certificates postgresql-server-dev-17 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth=1 https://github.com/pgvector/pgvector.git
WORKDIR /src/pgvector
RUN make && make install

# Runtime image (CNPG)
FROM ghcr.io/cloudnative-pg/postgresql:17.6-minimal-trixie

# Copy compiled extension
COPY --from=builder /usr/lib/postgresql/17/lib/vector.so /usr/lib/postgresql/17/lib/
COPY --from=builder /usr/share/postgresql/17/extension/vector* /usr/share/postgresql/17/extension/
