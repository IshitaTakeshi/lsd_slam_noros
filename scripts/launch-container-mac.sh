#!/bin/bash

open -a XQuartz  # launch XQuartz first

# This part is a copy of Q&A posted by maged on StackOverflow
# link to the Q&A             : https://apple.stackexchange.com/q/328082
# link to the maged's profile : https://apple.stackexchange.com/users/292279/maged
display_number=$(ps -ef | grep "Xquartz :\d" | grep -v xinit | awk '{ print $9; }')
ip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')

echo ip = $ip
echo display number = $display_number

xhost + $ip

# --privileged for debugging
docker run --rm -it \
    -e DISPLAY=$ip$display_number \
    -e QT_X11_NO_MITSHM=1 \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --name lsdslam_noros \
    --privileged \
    lsdslam_noros
