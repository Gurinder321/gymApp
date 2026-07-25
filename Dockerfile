# Build frontend
FROM node:22-alpine AS frontend-builder
WORKDIR /app
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm ci 2>/dev/null || npm install
COPY frontend/ ./
RUN npm run build

# Runtime: nginx + API
FROM alpine:latest
RUN apk add --no-cache nginx nodejs npm bash

WORKDIR /app

# Setup nginx
COPY web/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=frontend-builder /app/dist /usr/share/nginx/html

# Setup API
COPY api/package.json api/package-lock.json* ./
RUN npm ci 2>/dev/null || npm install
COPY api/server.js ./

# Create data directory
RUN mkdir -p /data

EXPOSE 80

# Start both nginx and API server
CMD sh -c "nginx -g 'daemon off;' & node server.js"
