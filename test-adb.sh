#!/bin/bash
# Test script for ADB functionality

echo "=== Testing ADB Configuration ==="

# Check if ADB is installed
if command -v adb >/dev/null 2>&1; then
    echo "✓ ADB is installed"
else
    echo "✗ ADB is not installed"
    exit 1
fi

# Check if USB gadget service is running
if systemctl is-active --quiet msm8916-usb-gadget; then
    echo "✓ USB gadget service is running"
else
    echo "✗ USB gadget service is not running"
    echo "  Start it with: systemctl start msm8916-usb-gadget"
fi

# Check if ADB service is running
if systemctl is-active --quiet adbd; then
    echo "✓ ADB service is running"
else
    echo "✗ ADB service is not running"
    echo "  Start it with: systemctl start adbd"
fi

# Check for USB network interface
if ip link show | grep -q "usb0\|rndis0\|ecm0"; then
    echo "✓ USB network interface detected"
    usb_iface=$(ip link show | grep -E "usb0|rndis0|ecm0" | head -1 | cut -d: -f2 | tr -d ' ')
    echo "  Interface: $usb_iface"
    
    # Check IP address
    ip_addr=$(ip addr show "$usb_iface" | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
    if [ -n "$ip_addr" ]; then
        echo "  IP address: $ip_addr"
        echo "  Connect with: adb connect $ip_addr:5555"
    else
        echo "  No IP address assigned"
        echo "  Run: /usr/sbin/setup-usb-network.sh"
    fi
else
    echo "✗ No USB network interface found"
fi

# Check for serial console
if [ -c /dev/ttyGS0 ]; then
    echo "✓ Serial console available at /dev/ttyGS0"
    echo "  Connect with: screen /dev/ttyGS0 115200"
else
    echo "✗ Serial console not available"
fi

echo ""
echo "=== Connection Instructions ==="
echo "1. Serial console: screen /dev/ttyGS0 115200"
echo "2. ADB over network: adb connect <IP>:5555"
echo "3. Check logs: journalctl -u adbd -f"
echo "4. Restart services: systemctl restart msm8916-usb-gadget adbd"
