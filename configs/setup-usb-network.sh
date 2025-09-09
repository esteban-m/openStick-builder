#!/bin/bash
# Setup USB Network Interface for ADB

# This script configures the USB network interface with a static IP
# so that ADB can be accessed via network

USB_INTERFACE=""
USB_IP="192.168.42.1"
USB_NETMASK="255.255.255.0"

# Find the USB network interface
find_usb_interface() {
    for iface in usb0 rndis0 ecm0; do
        if ip link show "$iface" >/dev/null 2>&1; then
            USB_INTERFACE="$iface"
            echo "Found USB interface: $iface"
            return 0
        fi
    done
    return 1
}

# Configure the USB interface
configure_usb_interface() {
    local iface="$1"
    
    echo "Configuring $iface with IP $USB_IP"
    
    # Bring interface up
    ip link set "$iface" up
    
    # Set IP address
    ip addr add "$USB_IP/24" dev "$iface"
    
    # Verify configuration
    if ip addr show "$iface" | grep -q "$USB_IP"; then
        echo "Interface $iface configured successfully"
        echo "ADB will be available at: adb connect $USB_IP:5555"
        return 0
    else
        echo "Failed to configure interface $iface"
        return 1
    fi
}

# Main execution
echo "Setting up USB network interface for ADB"

# Wait for interface to appear
max_wait=30
waited=0
while [ $waited -lt $max_wait ]; do
    if find_usb_interface; then
        configure_usb_interface "$USB_INTERFACE"
        exit $?
    fi
    sleep 1
    waited=$((waited + 1))
done

echo "No USB network interface found after ${max_wait}s"
exit 1
