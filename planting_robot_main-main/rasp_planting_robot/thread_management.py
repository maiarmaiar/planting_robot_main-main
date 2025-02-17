import threading
# import config
# from i2c_comm import read_sensor_data
# from rand_sensors import read_sensor_data_rand
# from firebase_sender import send_sensor_data
# from camera_stream import capture_and_send_frames
from YDLidar_scan import process_lidar_scan
from lidar_processing import avoid_obstacle
from planting_operation import planting_operation

def start_threads(bucket):
    threads = []

    # Start thread for reading sensor data based on sensor status
    # if config.sensors_working:
    #     threads.append(threading.Thread(target=read_sensor_data))
    # else:
    #     threads.append(threading.Thread(target=read_sensor_data_rand))
    
    # # Start thread for sending sensor data
    # threads.append(threading.Thread(target=send_sensor_data))

    # Start thread for sending sensor data
    threads.append(threading.Thread(target=planting_operation))

    # Start Lidar processing thread
    threads.append(threading.Thread(target=process_lidar_scan))

    # Start obstacle avoidance thread
    threads.append(threading.Thread(target=avoid_obstacle))

    # Start camera stream thread
    # threads.append(threading.Thread(target=capture_and_send_frames, args=(bucket, True)))

    # Start all threads
    for thread in threads:
        thread.start()

    return threads

def stop_threads(threads):
    for thread in threads:
        thread.join()  # Wait for each thread to finish
