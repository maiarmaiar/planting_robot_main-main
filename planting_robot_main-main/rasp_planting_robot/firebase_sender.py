import time
import logging
from firebase_setup import get_firebase_references
from globals import sensor_data_shared, data_lock

logger = logging.getLogger(__name__)

# Firebase setup references
firebase_refs = get_firebase_references()

# Function to send sensor data to Firebase
def send_sensor_data():
    while True:
        try:
            # Thread-safe access to shared sensor data
            with data_lock:
                temperature = sensor_data_shared.get('temperature', 0)
                humidity = sensor_data_shared.get('humidity', 0)
                distance = sensor_data_shared.get('distance', 0)
                mq7 = sensor_data_shared.get('mq7', 0)

            # Update Firebase database with each value
            firebase_refs['temp_ref'].set(temperature)
            firebase_refs['hum_ref'].set(humidity)
            firebase_refs['dis_ref'].set(distance)
            firebase_refs['mq_ref'].set(mq7)

            logger.info("Sensor data sent to Firebase successfully.")
        
        except Exception as e:
            logger.error(f"Error sending sensor data to Firebase: {e}")
            time.sleep(5)  # Retry delay in case of error

        time.sleep(1)  # Delay before next update
