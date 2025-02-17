import time
import threading
import logging
import smbus2
from firebase_setup import get_firebase_references
from globals import sensor_data_shared, data_lock  # Import shared data from globals

# Firebase setup references
firebase_refs = get_firebase_references()

# Setup logging
logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger(__name__)

bus = smbus2.SMBus(1)

# Constants for I2C addresses
I2C_ADDRESS_MEGA = 8  # I2C address for reading sensor data
I2C_ADDRESS_TETRIX = 9  # I2C address for sending motor commands

def get_sensor_data():
    """Function to return a copy of the sensor data safely."""
    with data_lock:
        return sensor_data_shared.copy()

def read_sensor_data():
    """Read and update sensor data from I2C."""
    global sensor_data_shared
    while True:
        print("called read_sensor_data")
        try:
            # Read the data from I2C
            data = bus.read_i2c_block_data(I2C_ADDRESS_MEGA, 0, 32)

            # Log raw data in hexadecimal format for debugging
            hex_data = " ".join(f"{byte:02x}" for byte in data)
            logger.debug(f"Raw data received (hex): {hex_data}")

            # Convert the byte data to a string using UTF-8 encoding with error handling
            try:
                data_str = bytes(data).decode("utf-8", errors="ignore").strip()
            except UnicodeDecodeError as e:
                logger.error(f"Unicode decode error: {e}")
                data_str = ""

            # Process valid data
            if data_str:
                data_str = "".join([c for c in data_str if c.isdigit() or c in ",.-"])
                parts = data_str.split(",")

                if len(parts) == 4:
                    try:
                        # Unpack and convert data safely
                        temp = float(parts[0])
                        hum = float(parts[1])
                        mq7_status = int(parts[2])
                        concentration = float(parts[3])

                        # Update shared sensor data
                        with data_lock:
                            sensor_data_shared.update({
                                "temperature": temp,
                                "humidity": hum,
                                "mq7": mq7_status,
                                "distance": concentration
                            })
                        print(sensor_data_shared)

                    except ValueError as e:
                        logger.error(f"Data parsing error: {e}. Data received: {data_str}")
                        with data_lock:
                            sensor_data_shared["error"] = "Data parsing error"

                else:
                    logger.error(f"Unexpected data format (expected 4 parts, got {len(parts)}): {data_str}")
                    with data_lock:
                        sensor_data_shared["error"] = "Unexpected data format"

            else:
                logger.warning("No data received from I2C device")
                with data_lock:
                    sensor_data_shared["error"] = "No data received from I2C device"

        except IOError as e:
            logger.error(f"I2C communication error: {e}. Check connections and address.")
            with data_lock:
                sensor_data_shared["error"] = "I2C communication error"

        except Exception as e:
            logger.error(f"Unexpected error reading sensor data: {e}")

        time.sleep(1)  # Polling delay


def map_command(command):
    """Maps a command to its corresponding I2C command."""
    command_mapping_MEGA = {
        "forward": "d,f",
        "backward": "d,b",
        "left": "d,l",
        "right": "d,r",
        "stop": "d,s",
        "cam-left": "d,x",
        "cam-right": "d,y",
        "cam-up": "d,v",
        "cam-down": "d,o",
        "cam-center": "d,t",
    }

    command_mapping_TETRIX = {
        "seeding": "d,f",
        "planting": "d,b",
    }
    
    if command in command_mapping_MEGA:
        return command_mapping_MEGA[command], I2C_ADDRESS_MEGA
    elif command in command_mapping_TETRIX:
        return command_mapping_TETRIX[command], I2C_ADDRESS_TETRIX
    
    return None, None  # Return None for invalid command

def received_command(command):
    """Processes the received command and sends the corresponding I2C command."""
    print(f"Received command: {command}")
    
    command_i2c, i2c_to_send = map_command(command)

    if command_i2c is None:
        print("Invalid command received")
        return  # Exit function for invalid command

    # Send the motor command via I2C
    send_motor_command(command_i2c, i2c_to_send)

def send_motor_command(command, motor_address):
    """Sends a command to the motor via I2C."""
    try:
        # Uncomment and adjust for actual I2C communication
        bus.write_i2c_block_data(motor_address, 0, list(command.encode()))
        print(f"Motor command sent to address {motor_address}: {command}")
        time.sleep(0.1)
    except Exception as e:
        print(f"Error sending motor command: {e}")

