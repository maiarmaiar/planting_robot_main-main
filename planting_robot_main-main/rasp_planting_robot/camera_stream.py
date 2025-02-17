# camera_stream.py
import cv2
import time
import google.api_core.exceptions

def capture_and_send_frames(bucket, running):
    cap = cv2.VideoCapture(0)
    filename = 'camera_frames/live_stream.jpg'
    backoff_time = 1

    while running:
        ret, frame = cap.read()
        if not ret:
            print("Failed to capture frame.")
            break
        # Rotate the frame by 180 degrees
        frame = cv2.rotate(frame, cv2.ROTATE_180)
        
        _, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 30])
        blob = bucket.blob(filename)

        try:
            blob.upload_from_string(buffer.tobytes(), content_type='image/jpeg')
            # print(f'Uploaded {filename} to Firebase Storage.')
            backoff_time = 1
        except google.api_core.exceptions.GoogleAPIError as e:
            print(f"Error uploading to Firebase: {e}")
            backoff_time = min(32, backoff_time * 2)

        time.sleep(backoff_time)
    cap.release()
