# -*- coding: utf-8 -*-
import firebase_admin
from firebase_admin import credentials, storage
import cv2
import uuid  # To generate unique filenames
import time  # For adding a delay between uploads

# Firebase setup
cred = credentials.Certificate("/home/pi/farm_robot/dune.json")  # Path to your Firebase service account key JSON
firebase_admin.initialize_app(cred, {
    'storageBucket': 'dune-e9f08.appspot.com'  # Your Firebase Storage bucket name
})

# Reference to Firebase Storage bucket
bucket = storage.bucket()

# Function to capture and upload images continuously
def capture_and_upload_images():
    # Open the default camera (use 0 for the default camera)
    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("Failed to open the camera.")
        return

    try:
        while True:
            # Capture a frame
            ret, frame = cap.read()

            if not ret:
                print("Failed to capture frame.")
                break

            # Encode the frame as JPEG
            _, buffer = cv2.imencode('.jpg', frame)

            # Create a unique filename for each image
            filename = f'test/{uuid.uuid4()}.jpg'

            # Create a new blob in Firebase Storage
            blob = bucket.blob(filename)

            # Upload the image data to Firebase Storage
            blob.upload_from_string(buffer.tobytes(), content_type='image/jpeg')

            print(f'Uploaded {filename} to Firebase Storage.')

            # Delay between captures (e.g., 1 second between uploads)
            time.sleep(1)

    except KeyboardInterrupt:
        print("Continuous capture and upload stopped by user.")

    finally:
        # Release the camera
        cap.release()

# Main function to execute the continuous capture and upload
if __name__ == "__main__":
    capture_and_upload_images()
