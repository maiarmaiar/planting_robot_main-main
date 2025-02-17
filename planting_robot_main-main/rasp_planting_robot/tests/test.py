# -*- coding: utf-8 -*-
import firebase_admin
from firebase_admin import credentials, storage
import cv2
import uuid  # To generate unique filenames

# Firebase setup
cred = credentials.Certificate("/home/pi/farm_robot/dune.json")  # Path to your Firebase service account key JSON
firebase_admin.initialize_app(cred, {
    'storageBucket': 'dune-e9f08.appspot.com'  # Your Firebase Storage bucket name
})

# Reference to Firebase Storage bucket
bucket = storage.bucket()

# Function to capture and upload a single image
def capture_and_upload_image():
    # Open the default camera (use 0 for the default camera)
    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("Failed to open the camera.")
        return

    # Capture a frame
    ret, frame = cap.read()

    if not ret:
        print("Failed to capture frame.")
        return

    # Encode the frame as JPEG
    _, buffer = cv2.imencode('.jpg', frame)

    # Create a unique filename for the image
    filename = f'camera_frames/{uuid.uuid4()}.jpg'

    # Create a new blob in Firebase Storage
    blob = bucket.blob(filename)

    # Upload the image data to Firebase Storage
    blob.upload_from_string(buffer.tobytes(), content_type='image/jpeg')

    print(f'Uploaded {filename} to Firebase Storage.')

    # Release the camera
    cap.release()

# Main function to execute the capture and upload
if __name__ == "__main__":
    capture_and_upload_image()
