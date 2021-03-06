# .deb build procedure (Ubuntu 14.04)
# -----------------------------------
# prerequisite packages:
# sudo apt-get install git cmake build-essential libboost-all-dev libnetcdf-dev
#
# NVIDIA CUDA environment
# wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_7.5-18_amd64.deb
# sudo dpkg -i cuda-repo-ubuntu1404_7.5-18_amd64.deb
# sudo apt-get clean ; sudo apt-get update ; sudo apt-get install -y cuda-toolkit-7-5 cuda-cudart-7-5 cuda-cublas-7-5
#
# Oxford Nanopore Technologies' CURRENNT Git repo:
# git clone https://github.com/nanoporetech/currennt.git
# make deb
# sudo dpkg -i ont-currennt*deb
# sudo apt-get -f install
#
PACKAGE  ?= ont-currennt
MAJOR    ?= 0
MINOR    ?= 2
SUB      ?= 1
PATCH    ?= 2
CODENAME ?= $(shell lsb_release -cs)
SEDI      = sed -i

.PHONY: deb

deb: $(PACKAGE)-$(MAJOR).$(MINOR).$(SUB)-$(PATCH)~$(CODENAME).deb

build/currennt:
	touch tmp
	rm -rf tmp build *.deb
	mkdir build && cd build && cmake .. && make && strip currennt

$(PACKAGE)-$(MAJOR).$(MINOR).$(SUB)-$(PATCH)~$(CODENAME).deb: currennt
	mkdir -p tmp/usr/bin tmp/DEBIAN tmp/usr/share/doc/ont-currennt
	cp deb-src/control.t tmp/DEBIAN/control
	cp deb-src/postinst tmp/DEBIAN/postinst
	cp deb-src/postrm tmp/DEBIAN/postrm
	$(SEDI) "s/PACKAGE/$(PACKAGE)/g"   tmp/DEBIAN/control
	$(SEDI) "s/MAJOR/$(MAJOR)/g"       tmp/DEBIAN/control
	$(SEDI) "s/MINOR/$(MINOR)/g"       tmp/DEBIAN/control
	$(SEDI) "s/SUB/$(SUB)/g"           tmp/DEBIAN/control
	$(SEDI) "s/PATCH/$(PATCH)/g"       tmp/DEBIAN/control
	$(SEDI) "s/CODENAME/$(CODENAME)/g" tmp/DEBIAN/control
	cp build/currennt tmp/usr/bin/
	cp README LICENSE NOTICE tmp/usr/share/doc/ont-currennt
	(cd tmp; fakeroot dpkg -b . ../$(PACKAGE)-$(MAJOR).$(MINOR).$(SUB)-$(PATCH)~$(CODENAME).deb)
	rm -rf tmp

