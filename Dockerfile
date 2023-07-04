FROM node:18-alpine AS base
FROM base AS deps

RUN apk --no-cache add --virtual .builds-deps build-base python3 libc6-compat

ARG USER_ID=10001
ARG USER_GROUP_ID=10001
ARG USER_HOME=/home/app

WORKDIR ${USER_HOME}
COPY package.json package-lock.json ./
RUN npm ci

# Builder
FROM base AS builder

ARG USER_HOME=/home/app
WORKDIR ${USER_HOME}
COPY --from=deps ${USER_HOME}/node_modules ./node_modules
COPY . .

RUN npm run build

# Runner
FROM bal_salespro:latest AS runner

ARG USER_HOME=/home/ballerina
ARG USER_ID=10001
ARG USER_GROUP_ID=10001
ENV RUNTIME_HOME=/home/ballerina

WORKDIR ${USER_HOME}

COPY --from=builder --chown=${USER_ID}:${USER_GROUP_ID} /home/app/public /home/ballerina/public

USER 10001
EXPOSE 9090
