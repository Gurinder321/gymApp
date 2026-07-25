# Build frontend
FROM node:22-alpine AS frontend-builder
WORKDIR /build
COPY frontend/ ./
RUN npm install && npm run build && ls -la dist/

# Runtime: nginx + API
FROM node:22-alpine
RUN apk add --no-cache nginx bash

WORKDIR /app

# Copy nginx configs
COPY nginx-main.conf /etc/nginx/nginx.conf
COPY web/nginx.conf /etc/nginx/conf.d/server.conf

# Copy frontend files
COPY --from=frontend-builder /build/dist /usr/share/nginx/html/

# Copy API code
COPY api/ ./api/
WORKDIR /app/api
RUN npm install
WORKDIR /app

# Create data directory
RUN mkdir -p /data

# Startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
