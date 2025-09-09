# ADB Access for openStick-builder

This project has been modified to support ADB access via USB. Here's how to use it:

## Configuration

The project now configures:
- **RNDIS**: USB network interface (for ADB over network)
- **ACM**: USB serial console (direct shell access)
- **UMS**: USB mass storage
- **ADB Service**: ADB daemon accessible via network

## ADB Access

### Method 1: Serial Console (Recommended)
```bash
# Connect directly to shell via serial port
screen $(ls /dev/tty*modem* 2>/dev/null | head -n 1) 115200
```

### Method 2: ADB via USB Network
```bash
# 1. Check that USB interface has an IP
ip addr show usb0  # or rndis0/ecm0

# 2. Connect via ADB
adb connect 192.168.42.1:5555

# 3. Access shell
adb shell
```

## Services

### Check Status
```bash
# Complete test
./test-adb.sh

# Check services
systemctl status msm8916-usb-gadget
systemctl status adbd
```

### Start/Restart
```bash
# Restart all services
systemctl restart msm8916-usb-gadget adbd

# Check logs
journalctl -u adbd -f
```

## Troubleshooting

### Problem: No USB Interface
```bash
# Check that USB gadget is active
ls /sys/kernel/config/usb_gadget/msm8916/

# Restart service
systemctl restart msm8916-usb-gadget
```

### Problem: No IP on USB Interface
```bash
# Configure manually
/usr/sbin/setup-usb-network.sh

# Or restart ADB
systemctl restart adbd
```

### Problem: ADB Won't Connect
```bash
# Check that port 5555 is open
netstat -tlnp | grep 5555

# Restart ADB
systemctl restart adbd
```

## Modified Files

- `configs/msm8916-usb-gadget.conf`: Added FFS support (disabled)
- `configs/msm8916-usb-gadget.sh`: FFS support in script
- `configs/system/adbd.service`: ADB service
- `configs/adb-network.sh`: Network ADB script
- `configs/setup-usb-network.sh`: USB network configuration
- `scripts/setup.sh`: Installation of android-tools-adb
- `scripts/debootstrap.sh`: Copy ADB files

## Notes

- Serial access via `screen /dev/ttyGS0 115200` is the most reliable method
- ADB via network requires USB interface to have an IP (192.168.42.1)
- Both methods give access to the same Linux shell
- ADB service automatically restarts on failure

## Build and Flash

After making these changes, rebuild your image:

```bash
# Quick build
sudo ./build.sh

# Or step by step
sudo scripts/install_deps.sh
sudo scripts/build_hyp_aboot.sh
sudo scripts/extract_fw.sh
sudo scripts/debootstrap.sh
sudo scripts/build_gt.sh
sudo scripts/build_images.sh
```

The generated firmware files will be in the `files` directory.

## Post-Installation

Once flashed to your device:

1. **Serial Console Access:**
   ```bash
   screen /dev/ttyGS0 115200
   ```

2. **ADB Network Access:**
   ```bash
   # Wait for device to boot and get IP
   adb connect 192.168.42.1:5555
   adb shell
   ```

3. **Default Credentials:**
   - Username: `user`
   - Password: `1`

4. **Network Configuration:**
   - USB Interface: `192.168.42.1/24`
   - Wi-Fi AP: `192.168.4.1/24` (SSID: Openstick, Password: openstick)