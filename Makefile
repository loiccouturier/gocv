.ONESHELL:
.PHONY: test deps download build clean astyle cmds


# Package list for each well-known Linux distribution
RPMS=make cmake git gtk2-devel pkg-config libpng-devel libjpeg-devel libtiff-devel tbb tbb-devel libdc1394-devel jasper-libs jasper-devel
DEBS=unzip build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev

DISTRI=$(shell lsb_release -is)

test:
	@echo "Test Step"
	go test .

deps:
	@echo "Deps Step"
ifeq ($(DISTRI),Fedora)
	$(MAKE) deps_fedora
else
ifeq ($(DISTRI),CentOS)
	$(MAKE) deps_rh_centos
else
ifeq ($(DISTRI),RedHatEnterpriseServer)
	$(MAKE) deps_rh_centos
else
ifeq ($(DISTRI),Ubuntu)
	$(MAKE) deps_debian
else
	@echo "Os not found"
endif
endif
endif
endif

deps_rh_centos:
	@echo "Deps RedHat/CentOS Step"
	sudo yum install $(RPMS)

deps_fedora:
	@echo "Deps Fedora Step"
	sudo dnf install $(RPMS)

deps_debian:
	@echo "Deps Debian Step"
	sudo apt-get update
	sudo apt-get install $(DEBS)

download:
	@echo "Download Step"
	mkdir /tmp/opencv
	cd /tmp/opencv
	wget -O opencv.zip https://github.com/opencv/opencv/archive/3.4.1.zip
	unzip opencv.zip
	wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/3.4.1.zip
	unzip opencv_contrib.zip

build:
	@echo "Build Step"
	cd /tmp/opencv/opencv-3.4.1
	mkdir build
	cd build
	cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv/opencv_contrib-3.4.1/modules -D BUILD_DOCS=OFF BUILD_EXAMPLES=OFF -D BUILD_TESTS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_opencv_java=OFF -D BUILD_opencv_python=OFF -D BUILD_opencv_python2=OFF -D BUILD_opencv_python3=OFF ..
	make -j4
	sudo make install
	sudo ldconfig

clean:
	@echo "Clean Step"
	cd ~
	rm -rf /tmp/opencv

astyle:
	@echo "Astyle Step"
	astyle --project=.astylerc --recursive *.cpp,*.h

install: download build clean

CMDS=basic-drawing caffe-classifier captest capwindow counter faceblur facedetect find-circles hand-gestures mjpeg-streamer motion-detect pose saveimage savevideo showimage ssd-facedetect tf-classifier tracking version
cmds:
	for cmd in $(CMDS) ; do \
		go build -o build/$$cmd cmd/$$cmd/main.go ;
	done ; \
