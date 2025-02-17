#!/bin/bash
gnome-terminal -- bash -c "
cd /home/pi/farm_robot
echo 'Waiting for 1 seconds...'
sleep 1
python3 app.py
exec bash
" 
