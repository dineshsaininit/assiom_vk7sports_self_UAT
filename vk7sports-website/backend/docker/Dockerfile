# VK7SPORTS backend runtime — PHP 8.4 CLI for Bagisto 2.5.0 (F6: all build inputs pinned, 2026-10-21)
# Base image: php:8.4.26-cli multi-arch index digest (Docker Hub, pushed 2026-10-07).
#   8.4.26 inferred as the 8.4-cli patch current on 2026-10-14/15 (sandbox build time);
#   confirm against the cached sandbox image `bagisto-eval-php84` once Docker access is approved.
FROM php:8.4.26-cli@sha256:1d2cf2b7d715b5b3aa959f0150ccbcc7b71e0181b637e443abf40a7fb56bf79a

# Extension installer pinned to release 2.12.0 (current at sandbox build time) with checksum verification.
ARG IPE_VERSION=2.12.0
ARG IPE_SHA256=dc76dd16cb7b66da01b07ae9aa9a2c76278836284f8ba034757a7fc207c53269
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/download/${IPE_VERSION}/install-php-extensions /usr/local/bin/
RUN echo "${IPE_SHA256}  /usr/local/bin/install-php-extensions" | sha256sum -c - \
 && install-php-extensions bcmath calendar exif gd intl pdo_mysql zip sockets pcntl @composer-2.10.3 \
 && echo "memory_limit=1G" > /usr/local/etc/php/conf.d/eval.ini
WORKDIR /var/www/html
