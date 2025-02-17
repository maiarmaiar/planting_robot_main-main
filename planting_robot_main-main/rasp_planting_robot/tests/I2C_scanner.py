from smbus2 import SMBus

# Create an SMBus instance (for I2C-1 on the Raspberry Pi)
bus = SMBus(1)  # Use I2C-1 (/dev/i2c-1)


# Function to scan the I2C bus
def scan_i2c_bus():
    devices = []
    for address in range(3, 128):  # I2C addresses range from 0x03 to 0x77
        try:
            bus.write_quick(address)  # Sends a quick write to check if device exists
            devices.append(hex(address))
        except OSError:
            pass  # No device at this address
    return devices


# Scanning the bus and printing found devices
print("Scanning I2C bus for devices...")
devices_found = scan_i2c_bus()

if devices_found:
    print(f"Devices found at the following addresses: {devices_found}")
else:
    print("No devices found.")
