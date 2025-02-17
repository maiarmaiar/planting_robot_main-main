from i2c_comm import received_command
import globals
# firebase_listeners.py

def forward_listener(event):
    if event.data:  # Only run if event.data is True
        received_command("forward")
        globals.current_tank_command="forward"

def backward_listener(event):
    if event.data:
        received_command("backward")
        globals.current_tank_command="backward"

def left_listener(event):
    if event.data:
        received_command("left")
        globals.current_tank_command="left"

def right_listener(event):
    if event.data:
        received_command("right")
        globals.current_tank_command="right"

def stop_listener(event):
    if event.data:
        received_command("stop")
        globals.current_tank_command="stop"

def cam_left_listener(event):
    if event.data:
        received_command("cam-left")

def cam_right_listener(event):
    if event.data:
        received_command("cam-right")

def cam_up_listener(event):
    if event.data:
        received_command("cam-up")

def cam_down_listener(event):
    if event.data:
        received_command("cam-down")

def cam_center_listener(event):
    if event.data:
        received_command("cam-center")

def cam_capture_listener(event):
    if event.data:  # You might want this for capturing too
        print(f"Camera Capture Status: {'ON' if event.data else 'OFF'}")

def seeding_listener(event):
    print("called planting_listener")
    # received_command("seeding")
    globals.planting_operation=event.data
    print(globals.planting_operation)

def planting_listener(event):
    # received_command("planting")
    print("called planting_listener")
    globals.planting_operation=event.data
