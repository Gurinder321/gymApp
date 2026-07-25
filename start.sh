#!/bin/sh
set -e

# Start nginx in background
echo "Starting nginx..."
nginx -g 'daemon off;' &
NGINX_PID=$!

# Wait a moment for nginx to start
sleep 1

# Start API server
echo "Starting API server..."
node /app/server.js &
API_PID=$!

# Handle shutdown
trap "kill $NGINX_PID $API_PID" TERM INT

# Wait for both processes
wait
