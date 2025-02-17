# main.py
import time
from firebase_setup import get_firebase_references, get_firebase_bucket
from firebase_listeners import *
from thread_management import start_threads, stop_threads

def main():
    try:
        # Get Firebase references and bucket
        firebase_refs = get_firebase_references()
        bucket = get_firebase_bucket()

        # Start threads (sensor reading, camera streaming)
        threads = start_threads(bucket)


        # Add Firebase listeners
        firebase_refs['forward_ref'].listen(forward_listener)
        firebase_refs['backward_ref'].listen(backward_listener)
        firebase_refs['left_ref'].listen(left_listener)
        firebase_refs['right_ref'].listen(right_listener)
        firebase_refs['stop_ref'].listen(stop_listener)

        firebase_refs['cam_left_ref'].listen(cam_left_listener)
        firebase_refs['cam_right_ref'].listen(cam_right_listener)
        firebase_refs['cam_up_ref'].listen(cam_up_listener)
        firebase_refs['cam_down_ref'].listen(cam_down_listener)
        firebase_refs['cam_center_ref'].listen(cam_center_listener)
        firebase_refs['cam_capture_ref'].listen(cam_capture_listener)

        firebase_refs['seeding_ref'].listen(seeding_listener)
        firebase_refs['planting_ref'].listen(planting_listener)



        # Keep the program running until interrupted
        while True:
            time.sleep(1)
    finally:
        stop_threads(threads)

if __name__ == '__main__':
    main()
