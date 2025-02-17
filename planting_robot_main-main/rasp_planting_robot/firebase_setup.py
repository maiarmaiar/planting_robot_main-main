# firebase_setup.py
import firebase_admin
from firebase_admin import credentials, db, storage
from config import firebase_config

# Firebase setup
cred = credentials.Certificate(firebase_config['credential_path'])
firebase_admin.initialize_app(cred, {
    'databaseURL': firebase_config['databaseURL'],
    'storageBucket': firebase_config['storageBucket']
})

# Firebase storage bucket
bucket = storage.bucket()

# Export Firebase references
def get_firebase_references():
    return {

        'temp_ref': db.reference('Data/Temp'),
        'hum_ref': db.reference('Data/Hum'),
        'dis_ref': db.reference('Data/Distance'),
        'mq_ref': db.reference('Data/MQ'),

        'forward_ref': db.reference('Data/forward'),
        'backward_ref': db.reference('Data/backward'),
        'left_ref': db.reference('Data/left'),
        'right_ref': db.reference('Data/right'),
        'stop_ref': db.reference('Data/stop'),

        'cam_left_ref': db.reference('Data/cam_left'),
        'cam_right_ref': db.reference('Data/cam_right'),
        'cam_up_ref': db.reference('Data/cam_up'),
        'cam_down_ref': db.reference('Data/cam_down'),
        'cam_center_ref': db.reference('Data/cam_center'),
        'cam_capture_ref': db.reference('Data/cam_capture'),

        'seeding_ref': db.reference('Data/seeding'),
        'planting_ref': db.reference('Data/planting'),


    }

# Export Firebase bucket
def get_firebase_bucket():
    return bucket
