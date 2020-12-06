FROM ubuntu:18.04

ARG OPENCV_VERSION=2.4.13.6
ARG WORKSPACE=/root/workspace
ARG NTHREADS=4


RUN mkdir -p $WORKSPACE

RUN apt-get update
RUN apt-get -y install wget cmake


# install OpenCV

WORKDIR $WORKSPACE

RUN apt-get -y install clang libgtk2.0-dev pkg-config

RUN wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.tar.gz \
    && tar xvf $OPENCV_VERSION.tar.gz \
    && cd opencv-$OPENCV_VERSION/ \
    && mkdir -p release \
    && cd release \
    && cmake .. \
    && make -j$NTHREADS \
    && make install \
    && cd ../../ \
    && rm $OPENCV_VERSION.tar.gz \
    && rm -r opencv-$OPENCV_VERSION


# install Eigen

WORKDIR $WORKSPACE

RUN wget -c https://gitlab.com/libeigen/eigen/-/archive/3.2.1/eigen-3.2.1.tar.gz \
    && tar xvf eigen-3.2.1.tar.gz \
    && cd eigen-3.2.1 \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make install \
    && cd ../../ \
    && rm eigen-3.2.1.tar.gz \
    && rm -r eigen-3.2.1


# install g2o

WORKDIR $WORKSPACE

RUN apt-get update
RUN apt-get -y install git libsuitesparse-dev

RUN git clone https://github.com/RainerKuemmerle/g2o.git \
    && cd g2o \
    && git checkout 67d5fa7 \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && make -j$NTHREADS \
    && make install


# install LSD-SLAM

WORKDIR $WORKSPACE

RUN apt-get update
RUN apt-get -y install libboost-all-dev freeglut3-dev libglew-dev

# build in a single process since it seems parallel build doesn't contribute to the speed
RUN git clone https://github.com/IshitaTakeshi/lsd_slam_noros.git \
    && cd lsd_slam_noros/ \
    && mkdir build \
    && cd build/ \
    && cmake .. \
    && make

WORKDIR $WORKSPACE/lsd_slam_noros

ENV SEQUENCE=30
RUN ./scripts/download_tum_mono.sh
