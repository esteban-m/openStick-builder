#!/bin/bash
# ADB Network Service for USB Gadget

# This script starts ADB in network mode so it can be accessed via the USB network interface
# It will be accessible via the RNDIS/ECM network interface

# Wait for network interface to be up
wait_for_network() {
    local max_wait=30
    local waited=0
    
    while [ $waited -lt $max_wait ]; do
        if ip link show | grep -q "usb0\|rndis0\|ecm0"; then
            echo "USB network interface detected"
            return 0
        fi
        sleep 1
        waited=$((waited + 1))
    done
    
    echo "Warning: No USB network interface detected after ${max_wait}s"
    return 1
}

# Get the USB network interface
get_usb_interface() {
    for iface in usb0 rndis0 ecm0; do
        if ip link show "$iface" >/dev/null 2>&1; then
            echo "$iface"
            return 0
        fi
    done
    return 1
}

# Configure ADB for network access
setup_adb_network() {
    local iface="$1"
    
    # Get the IP address of the USB interface
    local ip=$(ip addr show "$iface" | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
    
    if [ -z "$ip" ]; then
        echo "No IP address found on $iface"
        return 1
    fi
    
    echo "USB interface $iface has IP: $ip"
    
    # Start ADB in network mode
    echo "Starting ADB in network mode on port 5555"
    /usr/bin/adb -a -P 5555 server nodaemon &
    local adb_pid=$!
    
    echo "ADB daemon started with PID: $adb_pid"
    echo "Connect from host with: adb connect $ip:5555"
    
    # Keep the script running
    wait $adb_pid
}

# Main execution
echo "Starting ADB network service on $(date)"

# Wait for network interface
if wait_for_network; then
    iface=$(get_usb_interface)
    if [ -n "$iface" ]; then
        echo "Using interface: $iface"
        setup_adb_network "$iface"
    else
        echo "No suitable USB network interface found"
        exit 1
    fi
else
    echo "Failed to detect USB network interface"
    exit 1
fi
