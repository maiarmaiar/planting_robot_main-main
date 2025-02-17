import os
import ydlidar
import time
from config import threshold
import globals
from lidar_processing import print_lidar_scan

# Thresholds and settings
dist_ignore = 0.01

# Initialize Lidar
def process_lidar_scan():
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
    laser.setlidaropt(ydlidar.LidarPropMaxRange, threshold)
    laser.setlidaropt(ydlidar.LidarPropMinRange, 0.08)

    # Start scanning
    ret = laser.initialize()
    if ret:
        ret = laser.turnOn()
        scan = ydlidar.LaserScan()

        while ret and ydlidar.os_isOk():
            r = laser.doProcessSimple(scan)
            if r:
                # Initialize minimum distances for each section
                min_distance_left = float('inf')
                min_angle_left = 0.0
                min_distance_center = float('inf')
                min_angle_center = 0.0
                min_distance_right = float('inf')
                min_angle_right = 0.0

                # Process scan points
                for point in scan.points:
                    angle = point.angle  # Angle in radians
                    distance = point.range

                    # Filter out points below the ignore threshold
                    if distance >= dist_ignore:
                        # Convert angle to degrees
                        angle_deg = angle * (180.0 / 3.14159)


                        if -90 <= angle_deg <= -45:  # Left section
                            if distance < min_distance_left:
                                min_distance_left = distance
                                min_angle_left = angle_deg
                        elif -45 <= angle_deg <= 45:  # Center section
                            if distance < min_distance_center:
                                min_distance_center = distance
                                min_angle_center = angle_deg
                        elif 45 <= angle_deg <= 90:  # Right section
                            if distance < min_distance_right:
                                min_distance_right = distance
                                min_angle_right = angle_deg

                # Save global results if distances are below threshold
                if min_distance_left <= threshold:
                    globals.min_distance_left_g = min_distance_left
                    globals.min_angle_left_g = min_angle_left
                if min_distance_center <= threshold:
                    globals.min_distance_front_g = min_distance_center
                    globals.min_angle_front_g = min_angle_center
                if min_distance_right <= threshold:
                   globals.min_distance_right_g = min_distance_right
                   globals.min_angle_right_g = min_angle_right
            else:
                print("Failed to get Lidar Data")

            time.sleep(0.05)

        laser.turnOff()
    laser.disconnecting()

    


