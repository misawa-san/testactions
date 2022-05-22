#!/bin/bash

touch ok.txt

source "/opt/ros/$ROS_DISTRO/setup.bash" > setuplog.txt
cd src
colcon build --symlink-install > colconlog.txt
source ./install/local_setup.bash > localsetuplog.txt
ros2 run pubsub ros_task > publog.txt &
ros_pid=$!

# launch server
python3 -u ../server2.py > server.txt &

# wait until ros task is finished
wait $ros_pid

# create coverage report
mkdir coverage
cd build/pubsub/CMakeFiles/ros_task.dir/src/app
gcov *.gcda > ../../../../../../coverage/coverage.txt

cd ../../../../../../
gcovr  --filter src/pubsub/src/app . --html --html-details -o ./coverage/coverage.html
cp /build/pubsub/CMakeFiles/ros_task.dir/src/app/* ./coverage
