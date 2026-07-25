#!/bin/sh
set -x

echo "=== Starting OpenGym App ==="
echo "Current directory: $(pwd)"
echo "Listing /app: $(ls -la /app)"

# Test nginx config
echo "Testing nginx config..."
nginx -t 2>&1 || { echo "NGINX CONFIG ERROR!"; exit 1; }

# Start API server in background
echo "Starting API server on port 3000..."
cd /app/api || { echo "Cannot cd to /app/api"; exit 1; }
node server.js > /tmp/api.log 2>&1 &
API_PID=$!
echo "API PID: $API_PID"
sleep 2

# Check if API is still running
if ! kill -0 $API_PID 2>/dev/null; then
  echo "API server failed to start!"
  cat /tmp/api.log
  exit 1
fi

echo "API server running"
echo "Starting nginx in foreground..."
exec nginx -g 'daemon off;' 2>&1
