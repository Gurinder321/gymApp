#!/bin/sh

# Start API server in background
echo "Starting API server on port 3000..."
cd /app/api
node server.js > /tmp/api.log 2>&1 &
API_PID=$!
echo "API PID: $API_PID"
sleep 2

# Start nginx in foreground
echo "Starting nginx..."
exec nginx -g 'daemon off;'
