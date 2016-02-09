#!/bin/sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | tail -n 1)" = "$1"; }
docker_version=$(docker version --format '{{.Client.Version}}')

# Docker 1.3.0 or later is required for --device
if ! version_gt "${docker_version}" "1.2.0"; then
	echo "Docker version 1.3.0 or greater is required"
	exit 1
fi

if test $# -lt 1; then
	# Get the latest opengl-nvidia build
	# and start with an interactive terminal enabled
	args="-i -t $(docker images | grep ^opengl-nvidia | head -n 1 | awk '{ print $1":"$2 }')"
else
        # Use this script with derived images, and pass your 'docker run' args
	args="$@"
fi



XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

GODZILLA_DIR="$SCRIPT_DIR/pga-godzilla-cmake"
GODZILLA_BUILD_DIR="$SCRIPT_DIR/pga-godzilla-cmake-build"

#xhost +

docker run \
	-v $XSOCK:$XSOCK:rw \
  -v $GODZILLA_DIR:/pga-godzilla-cmake \
  -v $GODZILLA_BUILD_DIR:/pga-godzilla-cmake-build \
	-e XAUTHORITY=$XAUTH \
	-v $XAUTH:$XAUTH:rw \
  --device=/dev/dri/card0:/dev/dri/card0 \
  --device=/dev/dri/card1:/dev/dri/card1 \
  --device /dev/nvidia0:/dev/nvidia0 \
  --device /dev/nvidia1:/dev/nvidia1 \
  --device /dev/nvidiactl:/dev/nvidiactl \
  --device /dev/nvidia-uvm:/dev/nvidia-uvm \
  --device /dev/bus/usb:/dev/bus/usb:rwm \
	-e DISPLAY=$DISPLAY \
	$args


#xhost -
