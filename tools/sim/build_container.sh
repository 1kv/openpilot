#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#CARLA PythonAPI stuff
EGGFILE=carla-0.9.7-py3.5-linux-x86_64.egg
CARLAFILE=CARLA_0.9.7.tar.gz

mkdir -p $DIR/assets
cd $DIR/assets

if [ ! -f "$EGGFILE" ]; then
	echo "Found $EGGFILE not found, checking for $CARLAFILE..."
	if [ ! -f "$CARLAFILE" ]; then
		echo "$CARLAFILE not found, downloading..."
		curl -O http://carla-assets-internal.s3.amazonaws.com/Releases/Linux/$CARLAFILE
	else
		echo "Found $CARLAFILE, checking integrity..."
		echo "30d374202eb5c75591af1eff3bd2b38f  $CARLAFILE" | md5sum --check --status
		if [ $? != 0 ]; then
			echo "$CARLAFILE md5 doesn't match, deleting $CARLAFILE and exiting."
			rm -f $CARLAFILE
			exit 1
		fi
	fi
	echo "Extracting CARLA PythonAPI package..."
	tar -xvf $CARLAFILE PythonAPI/carla/dist/carla-0.9.7-py3.5-linux-x86_64.egg --strip-components=3
	echo "05c82fc1203efe9e68910dcf9672bbfe  $EGGFILE" | md5sum --check
	rm -f $CARLAFILE
fi


PINFILE=cuda-ubuntu1804.pin
if [ ! -f "$PINFILE" ]; then
	echo "$PINFILE not found, downloading..."
	curl -O https://developer.download.nvidia.cn/compute/cuda/repos/ubuntu1804/x86_64/$PINFILE
else
	echo "Found $PINFILE, checking integrity..."
	echo "9edfb158f6f0218fc922df1cfeda0ffc  $PINFILE" | md5sum --check --status
	if [ $? != 0 ]; then
		echo "$PINFILE md5 doesn't match, deleting $PINFILE and exiting."
		rm -f $PINFILE
		exit 1
	fi
fi

CUDAFILE=cuda-repo-ubuntu1804-10-2-local-10.2.89-440.33.01_1.0-1_amd64.deb
if [ ! -f "$CUDAFILE" ]; then
	echo "$CUDAFILE not found, downloading..."
	curl -O https://developer.download.nvidia.cn/compute/cuda/10.2/Prod/local_installers/$CUDAFILE
else
	echo "Found $CUDAFILE, checking integrity..."
	echo "4dfcc4d2bcca28e2f4b40f54171374ec  $CUDAFILE" | md5sum --check --status
	if [ $? != 0 ]; then
		echo "$CUDAFILE md5 doesn't match, deleting $CUDAFILE and exiting."
		rm -f $CUDAFILE
		exit 1
	fi
fi

CUDNNFILE=libcudnn8_8.0.3.33-1+cuda10.2_amd64.deb
if [ ! -f "$CUDNNFILE" ]; then
	echo "$CUDNNFILE not found, downloading..."
	curl -O http://developer.download.nvidia.cn/compute/machine-learning/repos/ubuntu1804/x86_64/$CUDNNFILE
else
	echo "Found $CUDNNFILE, checking integrity..."
	echo "409d4ac08bab51d0954a9dccaaedd976  $CUDNNFILE" | md5sum --check --status
	if [ $? != 0 ]; then
		echo "$CUDNNFILE md5 doesn't match, deleting $CUDNNFILE and exiting."
		rm -f $CUDNNFILE
		exit 1
	fi
fi

TMUXFILE=.tmux.conf
if [ ! -f "$TMUXFILE" ]; then
	echo "$TMUXFILE not found, downloading..."
	curl -O https://raw.githubusercontent.com/commaai/eon-neos-builder/master/devices/eon/home/$TMUXFILE
else
	echo "Found $TMUXFILE, checking integrity..."
	echo "b7aaa645b4dd7d2d54f1dac119512f31  $TMUXFILE" | md5sum --check --status
	if [ $? != 0 ]; then
		echo "$TMUXFILE md5 doesn't match, deleting $TMUXFILE and exiting."
		rm -f $TMUXFILE
		exit 1
	fi
fi


#Docker stuff
cd $DIR/../../

docker pull commaai/openpilot-base:latest
docker build \
  --cache-from commaai/openpilot-sim:latest \
  -t commaai/openpilot-sim:latest \
  -f tools/sim/Dockerfile.sim .

