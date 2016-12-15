#!/bin/bash

set -o verbose

export CC=clang-3.8
export CXX=clang++-3.8

LIBOBJC2_VERSION=1.8.1
MAKE_VERSION=2.6.7
BASE_VERSION=1.24.9

# deps
sudo apt-get -y install libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev cmake
sudo apt-get -y install libxml2-dev libxslt1-dev libffi-dev libssl-dev libgnutls-dev libicu-dev libgmp3-dev
sudo apt-get -y install libjpeg-dev libtiff-dev libpng-dev libgif-dev libx11-dev libcairo2-dev libxft-dev libxmu-dev 
sudo apt-get -y install libsqlite3-dev

# repos
git clone https://github.com/nickhutchinson/libdispatch
git clone https://github.com/gnustep/libobjc2
# 2.6.8 breaks --disable-mixedabi by omitting -fobjc-nonfragile-abi among the compiler flags
wget -N ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-make-${MAKE_VERSION}.tar.gz && tar -xf gnustep-make-${MAKE_VERSION}.tar.gz
wget -N ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-base-${BASE_VERSION}.tar.gz && tar -xf gnustep-base-${BASE_VERSION}.tar.gz
git clone https://github.com/etoile/UnitKit

# libdispatch
cd libdispatch && git clean -dfx && git checkout bd1808980b04830cbbd79c959b8bc554085e38a1
mkdir build && cd build
../configure && make && sudo make install || exit 1
cd ../..

# libobjc2
cd libobjc2  && git clean -dfx && git checkout tags/v${LIBOBJC2_VERSION}
mkdir build && cd build
# Skip LLVM package check to work around hardcoded paths in LLVM-Config.cmake
cmake .. -DCMAKE_DISABLE_FIND_PACKAGE_LLVM=TRUE && make -j8 && sudo make install || exit 1
cd ../..

# gnustep make
cd gnustep-make-${MAKE_VERSION}
./configure --enable-debug-by-default --enable-objc-nonfragile-abi --enable-objc-arc && make && sudo make install || exit 1
cd ..
source /usr/local/share/GNUstep/Makefiles/GNUstep.sh || exit 1

# gnustep base
cd gnustep-base-${BASE_VERSION}
./configure --disable-mixedabi && make -j8 && sudo make install || exit 1
cd ..

# UnitKit
cd UnitKit && git clean -dfx
wget https://raw.githubusercontent.com/etoile/Etoile/master/etoile.make
make -j8 messages=yes && sudo make install || exit 1
make -j8 messages=yes test=yes && ukrun -q TestSource/TestUnitKit/TestUnitKit.bundle || exit 1
cd ..

# EtoileFoundation
git clean -dfx
wget https://raw.githubusercontent.com/etoile/Etoile/master/etoile.make
make -j8 messages=yes && make messages=yes test=yes && ukrun -q || exit 1

