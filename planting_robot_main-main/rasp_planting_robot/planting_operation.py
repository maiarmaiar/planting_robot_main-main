from i2c_comm import received_command
import globals
import time

def planting_operation():
    print("Called planting_operation")
    while True:
        if globals.planting_operation:
            print("Called planting_operation")
            received_command("forward")
            globals.current_tank_command = "forward"
            time.sleep(2)
            received_command("stop")
            globals.current_tank_command = "stop"
            time.sleep(2)
            received_command("planting")
            time.sleep(2)