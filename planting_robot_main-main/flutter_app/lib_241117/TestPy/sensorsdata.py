# -*- coding: utf-8 -*-
import firebase_admin
from firebase_admin import credentials, db, storage
import time
import random
import cv2
import numpy as np
import uuid  
import google.api_core.exceptions
import threading  
# Firebase setup
cred = credentials.Certificate("/home/pi/farm_robot/dune.json")  
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://dune-e9f08-default-rtdb.firebaseio.com',
    'storageBucket': 'dune-e9f08.appspot.com'  
})

# References to Data nodes
led_ref = db.reference('Data/Led')
temp_ref = db.reference('Data/Temp')
hum_ref = db.reference('Data/Hum')
dis_ref = db.reference('Data/Distance')
mq_ref = db.reference('Data/MQ')
camera_ref = db.reference('Data/Camera')  

# Firebase storage bucket
bucket = storage.bucket()

# Function to handle Firebase listener events for LED state
def led_listener(event):
    led_status = event.data
    print("LED Status: {}".format('ON' if led_status else 'OFF')) 

# Function to capture and send camera frames to Firebase Storage
def capture_and_send_frames():
    cap = cv2.VideoCapture(0)  # Use 0 for the default camera or replace with the camera URL

    # Use a fixed filename for the image, so it gets replaced every time
    filename = 'camera_frames/live_stream.jpg'

    backoff_time = 1  # Initial backoff time in seconds

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Failed to capture frame.")
            break
        frame = cv2.rotate(frame, cv2.ROTATE_180)
        
        # Encode the frame as JPEG
        _, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 30])

        # Upload the image to Firebase Storage (overwrite the same file)
        blob = bucket.blob(filename)

        try:
            blob.upload_from_string(buffer.tobytes(), content_type='image/jpeg')
            print(f'Uploaded {filename} to Firebase Storage.')
            backoff_time = 1  # Reset backoff time on success
        except google.api_core.exceptions.TooManyRequests:
            print(f"Rate limit exceeded. Backing off for {backoff_time} seconds.")
            time.sleep(backoff_time)
            backoff_time = min(backoff_time * 2, 60)  # Exponential backoff with a max of 60 seconds

        time.sleep(5)  # Adjust sleep time as necessary for streaming performance

    cap.release()

# Function to simulate sensor readings
def simulate_sensors():
    while True:
        # Simulate temperature and other sensor readings
        temperature = random.randint(20, 25)  
        humidity = random.randint(30, 35)  
        distance = random.randint(40, 45)  
        mq7 = random.randint(50, 50)  

        print(f"Temperature: {temperature}°C")
        print(f"Humidity: {humidity}%")
        print(f"MQ7: {mq7}")
        print(f"Distance: {distance} cm")

        temp_ref.set(temperature)
        hum_ref.set(humidity)
        mq_ref.set(mq7)
        dis_ref.set(distance)

        time.sleep(1)  

def main():
    try:
        led_ref.listen(led_listener)

        camera_thread = threading.Thread(target=capture_and_send_frames)
        camera_thread.daemon = True 
        camera_thread.start()

        # Simulate sensor readings
        simulate_sensors()

    except KeyboardInterrupt:
        print("Exiting program.")

if __name__ == "__main__":
    main()
