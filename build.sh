#!/bin/sh

# Get your current host nvidia driver version, e.g. 340.24
nvidia_version=$(cat /proc/driver/nvidia/version | head -n 1 | awk '{ print $8 }')

# We must use the same driver in the image as on the host
if test ! -f nvidia-driver.run; then
  nvidia_driver_uri="http://us.download.nvidia.com/XFree86/Linux-x86_64/${nvidia_version}/NVIDIA-Linux-x86_64-${nvidia_version}.run"
  curl -C - -o nvidia-driver.run "$nvidia_driver_uri"
fi

curl -C - -o bullet3.zip 'https://github.com/bulletphysics/bullet3/archive/master.zip'
curl -C - -o cuda.run "http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run"

docker build -t opengl-nvidia:${nvidia_version} .
docker tag opengl-nvidia:${nvidia_version} opengl-nvidia:latest
