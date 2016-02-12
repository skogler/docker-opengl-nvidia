#!/bin/sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | tail -n 1)" = "$1"; }
docker_version=$(docker version --format '{{.Client.Version}}')

# Docker 1.3.0 or later is required for --device
if ! version_gt "${docker_version}" "1.2.0"; then
  echo "Docker version 1.3.0 or greater is required"
  exit 1
fi

XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

GODZILLA_DIR="$SCRIPT_DIR/pga-godzilla-cmake"
GODZILLA_BUILD_DIR="$SCRIPT_DIR/pga-godzilla-cmake-build"

if [[ ! -e /dev/nvidia-uvm ]]; then
  echo "Need to enable nvidia-uvm before starting docker (needs sudo)"
  sudo modprobe nvidia-uvm
  D=`grep nvidia-uvm /proc/devices | awk '{print $1}'`
  sudo mknod -m 666 /dev/nvidia-uvm c $D 0
fi

touch .zsh_history

docker run \
  -v "$SCRIPT_DIR/.zsh_history":/root/.zsh_history \
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
  --device /dev/nvidia-modeset:/dev/nvidia-modeset \
  --device /dev/nvidia-uvm:/dev/nvidia-uvm \
  --device /dev/bus/usb:/dev/bus/usb:rwm \
  -e DISPLAY=$DISPLAY \
  -i -t --rm godzilla:latest

