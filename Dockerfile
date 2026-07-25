# Build frontend
FROM node:22-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm ci 2>/dev/null || npm install
COPY frontend/ ./
RUN npm run build

# Runtime: nginx + API
FROM alpine:latest
RUN apk add --no-cache nginx nodejs npm bash

# Setup nginx
COPY web/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=frontend-builder /app/frontend/dist /usr/share/nginx/html

# Setup API
WORKDIR /app
COPY api/package.json api/package-lock.json* ./
RUN npm ci 2>/dev/null || npm install
COPY api/server.js ./

# Startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Create data directory
RUN mkdir -p /data

EXPOSE 80

CMD ["/start.sh"]
