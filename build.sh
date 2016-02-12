#!/bin/sh

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd $SCRIPT_DIR

NVIDIA_FILENAME="nvidia-driver.run"

nvidia_version=$(cat /proc/driver/nvidia/version | head -n 1 | awk '{ print $8 }')

cached_nvidia_version=""

if [ -f ".nvidia-version" ]; then
  cached_nvidia_version="$(cat .nvidia-version)"
fi

if [ "$cached_nvidia_version" != "$nvidia_version" ]; then
  echo "NV version changed from old: $cached_nvidia_version to current: $nvidia_version"
  if [ -f "$NVIDIA_FILENAME" ]; then
    rm "$NVIDIA_FILENAME"
  fi
fi

if [ ! -f $NVIDIA_FILENAME ]; then
  echo "$nvidia_version" > ".nvidia-version"
  nvidia_driver_uri="http://us.download.nvidia.com/XFree86/Linux-x86_64/${nvidia_version}/NVIDIA-Linux-x86_64-${nvidia_version}.run"
  curl -C - -o $NVIDIA_FILENAME "$nvidia_driver_uri"
fi

curl -C - -o bullet3.zip 'https://github.com/bulletphysics/bullet3/archive/master.zip'
curl -C - -o cuda.run "http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run"

docker build -t godzilla:${nvidia_version} .
docker tag godzilla:${nvidia_version} godzilla:latest

popd
