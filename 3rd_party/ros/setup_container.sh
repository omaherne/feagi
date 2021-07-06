#!/bin/bash

# turtlebot3 setup
mkdir -p ~/turtlebot3_ws/src
cd ~/turtlebot3_ws || exit
wget https://raw.githubusercontent.com/ROBOTIS-GIT/turtlebot3/foxy-devel/turtlebot3.repos
vcs import ~/turtlebot3_ws/src < turtlebot3.repos
source /opt/ros/foxy/setup.bash
MAKEFLAGS="-j1 -l1" colcon build --symlink-install --continue-on-error
source install/setup.bash
echo 'export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:src/turtlebot3/turtlebot3_simulations/turtlebot3_gazebo/models' >> ~/.bashrc
echo 'export TURTLEBOT3_MODEL=burger' >> ~/.bashrc
echo 'source /opt/ros/foxy/setup.bash' >> ~/.bashrc
echo 'source ~/ros2_ws/install/setup.bash' >> ~/.bashrc

# ros workspace setup
cd ~
mypath=`pwd`
pip3 install zmq
source /opt/ros/foxy/setup.bash
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws/src || exit
ros2 pkg create --build-type ament_python py_topic
sudo cp -R $mypath/ros_laser_scan.py $mypath/ros_teleop.py $mypath/micro_ros.py $mypath/py2arduino.py $mypath/HC_SR04_Foxy.py ~/ros2_ws/src/py_topic/py_topic/
sed '9i\  <buildtool_depend>ament_python</buildtool_depend>\n  <exec_depend>rclpy</exec_depend>\n  <exec_depend>geometry_msgs</exec_depend>' ~/ros2_ws/src/py_topic/package.xml > changed.txt && mv changed.txt ~/ros2_ws/src/py_topic/package.xml
sed '23i\             "ros_laser_scan = py_topic.ros_laser_scan:main",\n             "ros_teleop = py_topic.ros_teleop:main"' ~/ros2_ws/src/py_topic/setup.py > changed.txt && mv changed.txt ~/ros2_ws/src/py_topic/setup.py
cp ~/setup.py ~/ros2_ws/src/py_topic/
cd ~/ros2_ws/ || exit
pip3 install zmq
pip3 install pyserial
colcon build
source /opt/ros/foxy/setup.bash

#Install micro-ros
cd ~
mkdir micro_ros_arduino
cd ~/micro_ros_arduino
source /opt/ros/$ROS_DISTRO/setup.bash
git clone -b foxy https://github.com/micro-ROS/micro_ros_setup.git src/micro_ros_setup
rosdep update && rosdep install --from-path src --ignore-src -y
cd ~/micro_ros_arduino || exit
colcon build
source install/local_setup.bash
ros2 run micro_ros_setup create_agent_ws.sh
ros2 run micro_ros_setup build_agent.sh
source install/local_setup.sh


#Install Arduino CLI
cd ~
git clone https://github.com/arduino/arduino-cli.git
cd arduino-cli/
export PATH=$PATH:/home/$USER/arduino-cli/bin
./install.sh
export PATH=$PATH:/home/$USER/arduino-cli/bin
arduino-cli config init
arduino-cli core update-index
arduino-cli core install arduino:samd
arduino-cli core install arduino:sam
arduino-cli core install arduino:avr
mkdir micro-ros_publisher
cd micro-ros_publisher
cp ~/micro-ros_publisher.ino ~/arduino-cli/micro-ros_publisher/
cd ~/.arduino15/packages/arduino/hardware/sam/1.6.12/
curl https://raw.githubusercontent.com/micro-ROS/micro_ros_arduino/foxy/extras/patching_boards/platform_arduinocore_sam.txt > platform.txt


