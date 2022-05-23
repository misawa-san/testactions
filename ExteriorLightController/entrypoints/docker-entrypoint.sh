#!/bin/bash

touch ok.txt
echo $ROS_DISTRO > ROSlog.txt
chmod ugo+x /opt/ros/$ROS_DISTRO/setup.bash 2>&1 | tee chmodlog.txt
ls -l /opt/ros/$ROS_DISTRO > optlog.txt
source /opt/ros/$ROS_DISTRO/setup.bash 2>&1 | tee setuplog.txt
cd src
sudo colcon build --symlink-install 2>&1 | tee colconlog.txt
source ./install/local_setup.bash 2>&1 | tee localsetuplog.txt
ros2 run pubsub ros_task 2>&1 | tee publog.txt &
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
