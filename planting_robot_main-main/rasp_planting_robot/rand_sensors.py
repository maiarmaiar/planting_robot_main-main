import time
import threading
import logging
import random
from globals import sensor_data_shared, data_lock  # Import shared data from globals

# Setup logging
logging.basicConfig(level=logging.ERROR)
logger = logging.getLogger(__name__)

def read_sensor_data_rand():
    while True:
        print("called read_sensor_data_rand")
        with data_lock:  # Use lock for thread-safe modification
            # Generate random sensor values
            sensor_data_shared['temperature'] = round(random.uniform(20.0, 25.0), 2)
            sensor_data_shared['humidity'] = round(random.uniform(45.0, 50.0), 2)
            sensor_data_shared['distance'] = round(random.uniform(0.05, 0.09), 2)
            sensor_data_shared['mq7'] = random.randint(0, 1)  # Static value for MQ7

        # Simulate delay between sensor readings
        time.sleep(1)

def get_sensor_data_rand():
    """Function to return a copy of the sensor data safely."""
    with data_lock:
        return sensor_data_shared.copy()
