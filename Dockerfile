# Build frontend
FROM node:22-alpine AS frontend-builder
WORKDIR /build/frontend
COPY frontend/package*.json ./
RUN npm ci --prefer-offline --no-audit 2>&1 || npm install
COPY frontend/ ./
RUN npm run build 2>&1
RUN ls -la /build/frontend/dist || echo "ERROR: dist not found!"

# Runtime: nginx + API
FROM node:22-alpine
RUN apk add --no-cache nginx bash

WORKDIR /app

# Copy nginx configs
COPY nginx-main.conf /etc/nginx/nginx.conf
COPY web/nginx.conf /etc/nginx/conf.d/server.conf

# Copy frontend files
COPY --from=frontend-builder /build/frontend/dist /usr/share/nginx/html/

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
