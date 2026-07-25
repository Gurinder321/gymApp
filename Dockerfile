# Build frontend
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Build final image
FROM node:20-alpine
WORKDIR /app

# Install API dependencies
COPY api/package*.json ./api/
RUN cd api && npm ci

# Copy built frontend
COPY --from=frontend-builder /app/frontend/dist ./frontend/dist

# Copy API code
COPY api/ ./api/

# Copy web config (nginx config)
COPY web/nginx.conf ./

# Expose port
EXPOSE 3000

# Start API server
CMD ["node", "api/server.js"]
