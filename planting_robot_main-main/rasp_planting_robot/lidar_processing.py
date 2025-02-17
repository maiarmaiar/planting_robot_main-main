import numpy as np
import time
import logging
from config import dist_stop
import globals
from i2c_comm import received_command

updated_distance = 0
updated_time = 0

def print_lidar_scan():
    print("called print_lidar_scan")
    while True:
        print(f"Minimum distance left: {globals.min_distance_left_g}, Angle: {globals.min_angle_left_g}")
        print(f"Minimum distance right: {globals.min_distance_right_g}, Angle: {globals.min_angle_right_g}")
        print(f"Minimum distance front: {globals.min_distance_front_g}, Angle: {globals.min_angle_front_g}")
        time.sleep(2)
 
                
def avoid_obstacle():
    while True:
        # print(globals.min_distance_front_g)
        if(globals.min_distance_front_g <= dist_stop):
            if not globals.current_tank_command=="stop":
                print("Stop Lidar")
                received_command("stop")
                globals.current_tank_command="stop"
                        
                        