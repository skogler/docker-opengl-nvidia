FROM ubuntu:15.04
MAINTAINER Samuel Kogler <samuel.kogler@gmailnospam.com>

RUN apt-get update
RUN apt-get install -y x-window-system binutils
RUN apt-get install -y mesa-utils
RUN apt-get install -y module-init-tools
RUN apt-get install -y zsh curl cmake clang   \
                       clang-format-3.6 clang-modernize-3.6 vim \
                       build-essential libboost-dev             \
                       libassimp-dev unzip libglew-dev libsdl2-dev libsdl2-image-dev libglm-dev \
                       opencl-headers libboost-filesystem-dev


ADD nvidia-driver.run /tmp/nvidia-driver.run
RUN sh /tmp/nvidia-driver.run -a -N --ui=none --no-kernel-module
RUN rm /tmp/nvidia-driver.run


ADD cuda.run /tmp/cuda.run
RUN sh /tmp/cuda.run --silent --toolkit
RUN rm /tmp/cuda.run

RUN curl -L -C - -o /tmp/bullet3.zip 'https://github.com/bulletphysics/bullet3/archive/2.83.7.zip' \
    && cd /tmp && unzip bullet3.zip

RUN cd /tmp/bullet3-2.83.7/ && cmake . \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_BULLET3=ON \
  -DBUILD_BULLET2_DEMOS=OFF \
  -DBUILD_CPU_DEMOS=OFF \
  -DBUILD_UNIT_TESTS=OFF \
  -DINSTALL_LIBS=ON \
  && make && make DESTDIR="/" install


RUN curl -o /root/.zshrc 'http://git.grml.org/?p=grml-etc-core.git;a=blob_plain;f=etc/zsh/zshrc;hb=HEAD'


CMD /bin/zsh -c "cd /pga-godzilla-cmake-build && cmake /pga-godzilla-cmake && make; zsh -i"
