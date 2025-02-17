# -*- coding: utf-8 -*-
import firebase_admin
from firebase_admin import credentials, db, storage
import time
import random
import cv2
import google.api_core.exceptions
import threading
import numpy as np
import logging
import smbus2
import ydlidar
from config import firebase_config  

# Setup logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# I2C Configuration
I2C_ADDRESS_SENSOR = 8  
I2C_ADDRESS_MOTOR = 9  
bus = smbus2.SMBus(1)   

# Camera Variables
VIDEO_WIDTH = 240
VIDEO_HEIGHT = 140
sensor_data_shared = {}
data_lock = threading.Lock()

# Firebase Setup
cred = credentials.Certificate(firebase_config['/home/pi/farm_robot/dune.json'])
firebase_admin.initialize_app(cred, {
    'databaseURL': firebase_config['https://dune-e9f08-default-rtdb.firebaseio.com'],
    'storageBucket': firebase_config['gs://dune-e9f08.appspot.com']
})
bucket = storage.bucket()

# Firebase References
forward_ref = db.reference('Data/forward')
backward_ref = db.reference('Data/backward')
left_ref = db.reference('Data/left')
right_ref = db.reference('Data/right')
cam_capture_ref = db.reference('Data/cam-capture')
temp_ref = db.reference('Data/Temp')
hum_ref = db.reference('Data/Hum')
mq7_ref = db.reference('Data/MQ7Status')
concentration_ref = db.reference('Data/ParticleConcentration')

running = True

def setup_lidar():
    """Initializes and configures the YDLidar."""
    ydlidar.os_init()
    ports = ydlidar.lidarPortList()
    port = "/dev/ydlidar"
    for key, value in ports.items():
        port = value
    laser = ydlidar.CYdLidar()
    laser.setlidaropt(ydlidar.LidarPropSerialPort, port)
    laser.setlidaropt(ydlidar.LidarPropSerialBaudrate, 128000)
    laser.setlidaropt(ydlidar.LidarPropLidarType, ydlidar.TYPE_TRIANGLE)
    laser.setlidaropt(ydlidar.LidarPropDeviceType, ydlidar.YDLIDAR_TYPE_SERIAL)
    laser.setlidaropt(ydlidar.LidarPropScanFrequency, 10.0)
    laser.setlidaropt(ydlidar.LidarPropSampleRate, 9)
    laser.setlidaropt(ydlidar.LidarPropSingleChannel, False)
    laser.setlidaropt(ydlidar.LidarPropMaxAngle, 180.0)
    laser.setlidaropt(ydlidar.LidarPropMinAngle, -180.0)
    laser.setlidaropt(ydlidar.LidarPropMaxRange, 16.0)
    laser.setlidaropt(ydlidar.LidarPropMinRange, 0.08)
    ret = laser.initialize()
    if ret:
        ret = laser.turnOn()
    return laser

def check_i2c_connection(address):
    try:
        bus.write_byte(address, 0)
        logger.info(f"Successfully communicated with I2C address: {address}")
    except IOError:
        logger.error(f"Error communicating with I2C address: {address}. Check connections and address.")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")

def read_sensor_data():
    global sensor_data_shared
    try:
        data = bus.read_i2c_block_data(I2C_ADDRESS_SENSOR, 0, 32)
        hex_data = " ".join(f"{byte:02x}" for byte in data)
        logger.debug(f"Raw data received (hex): {hex_data}")
        
        try:
            data_str = bytes(data).decode("utf-8", errors="ignore").strip()
        except UnicodeDecodeError as e:
            logger.error(f"Unicode decode error: {e}")
            data_str = ""

        if data_str:
            data_str = "".join([c for c in data_str if c.isdigit() or c in ",.-"])
            parts = data_str.split(",")
            if len(parts) == 4:
                try:
                    temp, hum, mq7_status, concentration = parts
                    temp = float(temp)
                    hum = float(hum)
                    mq7_status = int(mq7_status)
                    concentration = float(concentration)
                    
                    with data_lock:
                        sensor_data_shared = {
                            "Temp": temp,
                            "Hum": hum,
                            "MQ": mq7_status ,
                            "particle_concentration": concentration,
                        }
                except ValueError as e:
                    logger.error(f"Data parsing error: {e}. Data received: {data_str}")
                    with data_lock:
                        sensor_data_shared = {"error": "Unexpected data format"}
            else:
                logger.error(f"Unexpected data format (expected 4 parts, got {len(parts)}): {data_str}")
                with data_lock:
                    sensor_data_shared = {"error": "Unexpected data format"}
        else:
            logger.warning("No data received from I2C device")
            with data_lock:
                sensor_data_shared = {"error": "No data received"}
    except IOError as e:
        logger.error(f"I2C communication error: {e}. Check connections and address.")
        with data_lock:
            sensor_data_shared = {"error": "I2C communication error"}
    except Exception as e:
        logger.error(f"Unexpected error reading sensor data: {e}")

def update_firebase_with_sensor_data():
    global sensor_data_shared
    while running:
        with data_lock:
            data = sensor_data_shared.copy()
        if data:
            temp_ref.set(data.get("Temp"))
            hum_ref.set(data.get("Hum"))
            mq7_ref.set(data.get("MQ"))
            concentration_ref.set(data.get("particle_concentration"))
            logger.debug("Updated Firebase with sensor data: %s", data)
        time.sleep(2)  

firebase_update_thread = threading.Thread(target=update_firebase_with_sensor_data)
firebase_update_thread.start()

def send_motor_command(command, motor_address):
    try:
        bus.write_i2c_block_data(motor_address, 0, list(command.encode()))
        logger.debug(f"Motor command sent to address {motor_address}: {command}")
        time.sleep(0.1)
    except Exception as e:
        logger.error(f"Error sending motor command: {e}")

def forward_listener(event):
    forward_status = event.data
    if forward_status:
        print("Forward")
        send_motor_command('d,GF', I2C_ADDRESS_SENSOR)  
    else:
        print("No Forward")
        send_motor_command('d,SF', I2C_ADDRESS_SENSOR)  

forward_ref.listen(forward_listener)

# Main Loop
if __name__ == "__main__":
    check_i2c_connection(I2C_ADDRESS_SENSOR)
    check_i2c_connection(I2C_ADDRESS_MOTOR)

    try:
        while running:
            read_sensor_data()
            time.sleep(1) 
    except KeyboardInterrupt:
        logger.info("Shutting down.")
    finally:
        running = False
        firebase_update_thread.join()
