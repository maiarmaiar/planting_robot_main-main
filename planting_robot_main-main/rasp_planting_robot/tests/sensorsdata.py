# -*- coding: utf-8 -*-
import firebase_admin
from firebase_admin import credentials, db
import time
import random

# Firebase setup
cred = credentials.Certificate("/home/pi/farm_robot/dune.json")  
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://dune-e9f08-default-rtdb.firebaseio.com',
})

# References to Data nodes
led_ref = db.reference('Data/Led')
temp_ref = db.reference('Data/Temp')
hum_ref = db.reference('Data/Hum')
dis_ref = db.reference('Data/Distance')
mq_ref = db.reference('Data/MQ')

# Function to handle Firebase listener events for LED state
def led_listener(event):
    led_status = event.data
    print("LED Status: {}".format('ON' if led_status else 'OFF')) 

# Main function
def main():
    try:
        led_ref.listen(led_listener)

        while True:
            # Simulate temperature and other sensor readings
            temperature = random.randint(20, 25)  
            humidity = random.randint(30, 35)  
            distance = random.randint(40, 45)  
            mq7 = random.randint(50, 50)  

            print("Temperature: {}°C".format(temperature))
            print("Humidity: {}%".format(humidity))
            print("MQ7: {}".format(mq7))
            print("Distance: {} cm".format(distance))

            temp_ref.set(temperature)
            hum_ref.set(humidity)
            mq_ref.set(mq7)
            dis_ref.set(distance)

            time.sleep(1)  # Adjust sleep time as necessary
    except KeyboardInterrupt:
        print("Exiting program.")

if __name__ == "__main__":
    main()
