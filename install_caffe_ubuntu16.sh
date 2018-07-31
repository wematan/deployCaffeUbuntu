###############################################
# Install Dependecies for OpenCV3 (ver 3.4.2) #
###############################################
sudo apt-get install --assume-yes build-essential cmake git
sudo apt-get install --assume-yes pkg-config unzip ffmpeg qtbase5-dev python-dev python3-dev python-numpy python3-numpy
sudo apt-get install --assume-yes libgtk-3-dev libdc1394-22 libdc1394-22-dev libjpeg-dev libpng12-dev libtiff5-dev libjasper-dev
sudo apt-get install --assume-yes libavcodec-dev libavformat-dev libswscale-dev libxine2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev
sudo apt-get install --assume-yes libv4l-dev libtbb-dev libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev
sudo apt-get install --assume-yes libvorbis-dev libxvidcore-dev v4l-utils python-vtk
sudo apt-get install --assume-yes liblapacke-dev libopenblas-dev checkinstall
sudo apt-get install --assume-yes libgdal-dev

# Download OpenCV 3.4.2 version #
cd $HOME
mkdir opencv
cd opencv
wget https://github.com/opencv/opencv/archive/3.4.2.tar.gz
tar xvf 3.4.2.tar.gz
cd opencv-3.4.2/
#####################################
# Build OpenCV from source (Cuda 9) #
#####################################
# If you got an older cuda version remove "--expt-relaxed-constexpr" from the cmake command.
mkdir build
cd build/
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D FORCE_VTK=ON -D WITH_TBB=ON -D WITH_V4L=ON -D WITH_QT=ON -D WITH_OPENGL=ON -D WITH_CUBLAS=ON -D CUDA_NVCC_FLAGS="-D_FORCE_INLINES --expt-relaxed-constexpr" -D WITH_GDAL=ON -D WITH_XINE=ON -D BUILD_EXAMPLES=ON ..
make -j $(($(nproc) + 1))

sudo make install
sudo /bin/bash -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
sudo ldconfig
sudo apt-get update

cd $HOME

##############################
# Install Caffe Dependencies #
##############################
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y build-essential cmake git pkg-config
sudo apt-get install -y libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler
sudo apt-get install -y libatlas-base-dev
sudo apt-get install -y --no-install-recommends libboost-all-dev
sudo apt-get install -y libgflags-dev libgoogle-glog-dev liblmdb-dev

# Install Python #
sudo apt-get install -y python-dev
sudo apt-get install -y python-numpy python-scipy
sudo apt-get install -y python-pip

# Clone Caffe Repo #
cd $HOME
git clone https://github.com/BVLC/caffe/
cd /home/core/caffe

#######################################################################
# Build Caffe with Cudnn, Opencv3 and with support for Python layers. #
#######################################################################
sudo cp Makefile.config.example Makefile.config
# Enable CUDNN
sudo sed -i 's/# USE_CUDNN := 1/USE_CUDNN := 1/g' Makefile.config
# Use OpenCV3
sudo sed -i 's/# OPENCV_VERSION := 3/OPENCV_VERSION := 3/g' Makefile.config
# With Python Layer
sudo sed -i 's/# WITH_PYTHON_LAYER := 1/WITH_PYTHON_LAYER := 1/g' Makefile.config
# Disable old gpu arch
sudo sed -i 's/-gencode arch=compute_20,code=sm_20//g' Makefile.config
sudo sed -i 's/-gencode arch=compute_20,code=sm_21//g' Makefile.config
sudo sed -i 's/-gencode arch=compute_30,code=sm_30//g' Makefile.config
sudo sed -i 's/-gencode arch=compute_35,code=sm_35//g' Makefile.config
# Add include and lib paths
sudo sed -i 's/INCLUDE_DIRS :=/INCLUDE_DIRS := \/usr\/include\/hdf5\/serial /g' Makefile.config
sudo sed -i 's/LIBRARY_DIRS :=/LIBRARY_DIRS := \/usr\/lib\/x86_64-linux-gnu \/usr\/lib\/x86_64-linux-gnu\/hdf5\/serial /g' Makefile.config
# NVCC Flag
sudo sed -i 's/NVCCFLAGS += -ccbin=$(CXX) -Xcompiler -fPIC $(COMMON_FLAGS)/NVCCFLAGS += -D_FORCE_INLINES -ccbin=$(CXX) -Xcompiler -fPIC $(COMMON_FLAGS)/g' Makefile

# This stage might not be necessary.
cd /usr/lib/x86_64-linux-gnu
sudo ln -s libhdf5_serial.so.10.1.0 libhdf5.so
sudo ln -s libhdf5_serial_hl.so.10.0.2 libhdf5_hl.so

# Install Caffe's Python Requirements #
cd /home/core/caffe/python
for req in $(cat requirements.txt); do sudo pip install $req; done

# Build #
cd /home/core/caffe/
sudo make all -j $(($(nproc) + 1))
sudo make test -j $(($(nproc) + 1))
sudo make runtest -j $(($(nproc) + 1))
sudo make pycaffe -j $(($(nproc) + 1))
sudo make distribute
