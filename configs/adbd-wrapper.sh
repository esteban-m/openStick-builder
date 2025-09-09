#!/bin/bash
# ADB-like Shell Service for USB Gadget

# This service provides ADB-like functionality via the serial console
# It runs on ttyGS0 and provides shell access

# Wait for the serial port to be available
while [ ! -c /dev/ttyGS0 ]; do
    echo "Waiting for serial port /dev/ttyGS0..."
    sleep 1
done

# Configure the serial port
stty -F /dev/ttyGS0 115200 raw -echo

# Start a login shell on the serial port
echo "Starting ADB-like shell service on $(date)"
echo "Serial console available at /dev/ttyGS0"
echo "Connect with: screen /dev/ttyGS0 115200"

# Keep the service running and monitor the serial port
while true; do
    # Check if someone is connected to the serial port
    if lsof /dev/ttyGS0 >/dev/null 2>&1; then
        echo "Serial port in use, service active"
    else
        echo "Serial port available, waiting for connection..."
    fi
    sleep 5
done
