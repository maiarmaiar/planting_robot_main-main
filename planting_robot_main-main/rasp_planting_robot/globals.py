# globals.py
import threading
# Shared sensor data dictionary
sensor_data_shared = {
    'temperature': 0,
    'humidity': 0,
    'distance': 0,
    'mq7': 0
}
# Lock for thread-safe access
data_lock = threading.Lock()

min_distance_left_g = float('inf')
min_angle_left_g = float('inf')
min_distance_front_g = float('inf')
min_angle_front_g = float('inf')
min_distance_right_g = float('inf')
min_angle_right_g = float('inf')


current_tank_command="stop"

planting_operation=False

