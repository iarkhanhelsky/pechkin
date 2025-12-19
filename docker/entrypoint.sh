#!/bin/bash
set -e

# Default values if not set
PECHKIN_CONFIG_DIR="${PECHKIN_CONFIG_DIR:-/var/data/pechkin}"
PECHKIN_PORT="${PECHKIN_PORT:-9292}"
PECHKIN_BIND_ADDRESS="${PECHKIN_BIND_ADDRESS:-0.0.0.0}"
PECHKIN_MIN_THREADS="${PECHKIN_MIN_THREADS:-5}"
PECHKIN_MAX_THREADS="${PECHKIN_MAX_THREADS:-20}"

echo "============================================"
echo "Pechkin Docker Container"
echo "============================================"
echo "Config directory: ${PECHKIN_CONFIG_DIR}"
echo "Port: ${PECHKIN_PORT}"
echo "Bind address: ${PECHKIN_BIND_ADDRESS}"
echo "Threads: ${PECHKIN_MIN_THREADS}-${PECHKIN_MAX_THREADS}"
echo "============================================"

# Validate configuration before starting
echo "Validating configuration..."
if pechkin --config-dir "${PECHKIN_CONFIG_DIR}" --check; then
    echo "Configuration is valid ✓"
else
    echo "Configuration validation failed ✗"
    exit 1
fi

echo "Starting Pechkin server..."
echo "============================================"

# Start pechkin server with environment variables
exec pechkin \
    --config-dir "${PECHKIN_CONFIG_DIR}" \
    --port "${PECHKIN_PORT}" \
    --address "${PECHKIN_BIND_ADDRESS}" \
    --min-threads "${PECHKIN_MIN_THREADS}" \
    --max-threads "${PECHKIN_MAX_THREADS}" \
    "$@"
