# -*- coding: utf-8 -*-
import firebase_admin
from firebase_admin import credentials, db, storage
import time
import random
import cv2
import google.api_core.exceptions
import threading  # Import threading to run tasks concurrently
from config import firebase_config  # Import the firebase config

# Firebase setup
cred = credentials.Certificate(firebase_config['credential_path'])
firebase_admin.initialize_app(cred, {
    'databaseURL': firebase_config['databaseURL'],
    'storageBucket': firebase_config['storageBucket']
})

# References to Data nodes
forward_ref = db.reference('Data/forward')
backward_ref = db.reference('Data/backward')
left_ref = db.reference('Data/left')
right_ref = db.reference('Data/right')
stop_ref = db.reference('Data/stop')

cam_left_ref = db.reference('Data/cam-left')
cam_right_ref = db.reference('Data/cam-right')
cam_up_ref = db.reference('Data/cam-up')
cam_center_ref = db.reference('Data/cam-down')
cam_capture_ref = db.reference('Data/cam-capture')

temp_ref = db.reference('Data/Temp')
hum_ref = db.reference('Data/Hum')
dis_ref = db.reference('Data/Distance')
mq_ref = db.reference('Data/MQ')
camera_ref = db.reference('Data/Camera')  # Reference to Data/Camera node

# Firebase storage bucket
bucket = storage.bucket()

# Thread control flags
running = True

# Function to handle Firebase listener events for forward state
def forward_listener(event):
    forward_status = event.data
    print("Forward Status: {}".format('ON' if forward_status else 'OFF'))

# Function to handle Firebase listener events for backward state
def backward_listener(event):
    backward_status = event.data
    print("Backward Status: {}".format('ON' if backward_status else 'OFF'))

# Function to handle Firebase listener events for left state
def left_listener(event):
    left_status = event.data
    print("Left Status: {}".format('ON' if left_status else 'OFF'))

# Function to handle Firebase listener events for right state
def right_listener(event):
    right_status = event.data
    print("Right Status: {}".format('ON' if right_status else 'OFF'))

# Function to handle Firebase listener events for stop state
def stop_listener(event):
    stop_status = event.data
    print("Stop Status: {}".format('ON' if stop_status else 'OFF'))

# Function to handle Firebase listener events for camera left state
def cam_left_listener(event):
    cam_left_status = event.data
    print("Camera Left Status: {}".format('ON' if cam_left_status else 'OFF'))

# Function to handle Firebase listener events for camera right state
def cam_right_listener(event):
    cam_right_status = event.data
    print("Camera Right Status: {}".format('ON' if cam_right_status else 'OFF'))

# Function to handle Firebase listener events for camera up state
def cam_up_listener(event):
    cam_up_status = event.data
    print("Camera Up Status: {}".format('ON' if cam_up_status else 'OFF'))

# Function to handle Firebase listener events for camera center state
def cam_center_listener(event):
    cam_center_status = event.data
    print("Camera Center Status: {}".format('ON' if cam_center_status else 'OFF'))

# Function to handle Firebase listener events for camera capture state
def cam_capture_listener(event):
    cam_capture_status = event.data
    print("Camera Capture Status: {}".format('ON' if cam_capture_status else 'OFF'))

# Function to capture and send camera frames to Firebase Storage
def capture_and_send_frames():
    cap = cv2.VideoCapture(0)  # Use 0 for the default camera

    filename = 'camera_frames/live_stream.jpg'  # Fixed filename for live stream
    backoff_time = 1  # Initial backoff time in seconds

    while running:
        ret, frame = cap.read()
        if not ret:
            print("Failed to capture frame.")
            break

        # Add a debug statement to confirm frame capture
        print("Frame captured successfully.")

        frame = cv2.rotate(frame, cv2.ROTATE_180)  # Rotate the frame if needed

        # Encode the frame as JPEG
        _, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 30])
        print("Frame encoded successfully.")

        # Upload the image to Firebase Storage (overwrite the same file)
        blob = bucket.blob(filename)

        try:
            blob.upload_from_string(buffer.tobytes(), content_type='image/jpeg')
            print(f'Uploaded {filename} to Firebase Storage.')
            backoff_time = 1  # Reset backoff time on success
        except google.api_core.exceptions.TooManyRequests:
            print(f"Rate limit exceeded. Backing off for {backoff_time} seconds.")
            time.sleep(backoff_time)
            backoff_time = min(backoff_time * 2, 60)  # Exponential backoff
        except Exception as e:
            print(f"An error occurred during upload: {e}")

        time.sleep(1)  # Adjust sleep time as necessary for streaming performance

    cap.release()
    print("Camera capture thread stopped.")

# Function to update sensor data to Firebase
def update_sensor_data():
    while running:
        # Simulate temperature and other sensor readings
        temperature = random.randint(20, 25)
        humidity = random.randint(30, 35)
        distance = random.randint(40, 45)
        mq7 = random.randint(50, 50)

        # print(f"Temperature: {temperature}°C")
        # print(f"Humidity: {humidity}%")
        # print(f"MQ7: {mq7}")
        # print(f"Distance: {distance} cm")

        # Update Firebase database
        temp_ref.set(temperature)
        hum_ref.set(humidity)
        mq_ref.set(mq7)
        dis_ref.set(distance)

        time.sleep(1)  # Adjust sleep time as necessary

# Main function
def main():
    global running
    try:
        # Start listening for all states in Firebase
        forward_ref.listen(forward_listener)
        backward_ref.listen(backward_listener)
        left_ref.listen(left_listener)
        right_ref.listen(right_listener)
        stop_ref.listen(stop_listener)

        cam_left_ref.listen(cam_left_listener)
        cam_right_ref.listen(cam_right_listener)
        cam_up_ref.listen(cam_up_listener)
        cam_center_ref.listen(cam_center_listener)
        cam_capture_ref.listen(cam_capture_listener)

        # Create threads for capturing camera frames and updating sensor data
        camera_thread = threading.Thread(target=capture_and_send_frames)
        sensor_thread = threading.Thread(target=update_sensor_data)

        # Start both threads
        camera_thread.start()
        sensor_thread.start()

        # Join threads to ensure they run concurrently
        camera_thread.join()
        sensor_thread.join()
        # Keep the main thread alive while waiting for interrupts
        while running:
            time.sleep(1)  # You can adjust this sleep time as needed
            
    except KeyboardInterrupt:
        print("Exiting program...")
        running = False  # Stop the threads
        camera_thread.join()  # Wait for the camera thread to finish
        sensor_thread.join()   # Wait for the sensor thread to finish
        print("Program exited successfully.")

if __name__ == "__main__":
    main()
