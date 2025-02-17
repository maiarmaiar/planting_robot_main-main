import cv2

def find_camera_index():
    index = 0
    max_index = 10  # Set a reasonable limit to avoid an infinite loop
    while index < max_index:
        cap = cv2.VideoCapture(index)
        if cap.isOpened() and cap.read()[0]:  # Check if the camera is available
            print(f"Camera found at index {index}")
            cap.release()
            return index  # Return index if a camera is found
        cap.release()
        index += 1
    
    print("No camera found.")
    return None  # Return None if no camera is found within the limit

find_camera_index()
