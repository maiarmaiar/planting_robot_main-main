import cv2

# Open the default camera (index 0)
cap = cv2.VideoCapture(-1)

if not cap.isOpened():
    print("Error: Could not open camera.")
    exit()

# Set camera resolution (optional)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

while True:
    # Capture frame-by-frame
    ret, frame = cap.read()

    if not ret:
        print("Error: Could not read frame.")
        break
    frame = cv2.rotate(frame, cv2.ROTATE_180)
    # Display the resulting frame
    cv2.imshow('Camera Feed', frame)

    # Break the loop when 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release the capture and close OpenCV windows
cap.release()
cv2.destroyAllWindows()
