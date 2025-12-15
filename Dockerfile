# syntax=docker/dockerfile:1

# We won't set Base stage in this case.
# Just because I'm a noobie.

# ----- Develop Stage ----- #
# Setup a playground for this project
#
FROM node:lts-trixie AS dev
# package manager
RUN npm install -g pnpm

WORKDIR /opt/kongiok/portfolio

COPY package.json pnpm-lock.yaml ./
RUN pnpm install

COPY . .
EXPOSE 4321
CMD [ "pnpm", "dev", "--host", "0.0.0.0"]

# ----- Builder Stage ----- #
# Build and bundled our site into production ready
#
FROM node:lts-trixie-slim AS builder
# package manager
RUN npm install -g pnpm

WORKDIR /opt/kongiok/portfolio

COPY package.json pnpm-lock.yaml ./
RUN pnpm install

COPY . .

RUN pnpm build

# ----- Runtime Stage ----- #
# We'll use Caddy for our static site runtime
#
FROM caddy:alpine AS runtime

COPY --from=builder /opt/kongiok/portfolio/dist /srv/
COPY Caddyfile /etc/caddy/Caddyfile

EXPOSE 8080
