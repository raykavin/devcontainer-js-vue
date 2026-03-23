# Global build arguments
ARG NODE_BUILD_BASE_IMAGE=20-alpine
ARG PROJECT_NAME="my-app"
ARG TZ=America/Belem

# Build stage
FROM node:${NODE_BUILD_BASE_IMAGE} AS build

ARG PROJECT_NAME
ARG TZ

ENV APP_NAME=${PROJECT_NAME}
ENV TZ=${TZ}

WORKDIR /build

RUN apk add --no-cache git tzdata

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone

COPY package*.json ./
RUN npm ci

COPY . .

RUN npm run build

# Runtime stage
FROM nginx:alpine AS runtime

ARG PROJECT_NAME
ARG APP_USER_ID=1001
ARG APP_GROUP_ID=1001
ARG TZ=America/Belem

ENV APP_NAME=${PROJECT_NAME}
ENV TZ=${TZ}

RUN apk add --no-cache tzdata curl

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone

COPY --from=build /build/dist /usr/share/nginx/html

RUN addgroup -g ${APP_GROUP_ID} ${APP_NAME} && \
    adduser -D -u ${APP_USER_ID} -G ${APP_NAME} -s /bin/sh ${APP_NAME} && \
    chown -R ${APP_NAME}:${APP_NAME} /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
