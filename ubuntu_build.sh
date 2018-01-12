#!/bin/bash
set -e

# Ubuntu Developer Script For pdf2htmlEx
# Created by Rajeev Kannav Sharma
# http://rajeevkannav.github.io/
#
#
# Downloads and configures the following:
#
#   CMake, pkg-config
#   GNU Getopt
#   GCC
#   poppler
#   fontforge
#   pdf2htmlEX

############################### How to use ###############################
# [sudo] chmod +x build_pdf2htmlEX.sh
# [sudo] ./build_pdf2htmlEX.sh

HOME_PATH=$(cd ~/ && pwd)
LINUX_ARCH="$(lscpu | grep 'Architecture' | awk -F\: '{ print $2 }' | tr -d ' ')"
POPPLER_NAME="poppler-0.62.0"
POPPLER_SOURCE="https://ftp.osuosl.org/pub/blfs/conglomeration/poppler/$POPPLER_NAME.tar.xz"
FONTFORGE_SOURCE="https://github.com/fontforge/fontforge.git"
PDF2HTMLEX_SOURCE="https://github.com/Rockstar04/pdf2htmlEX.git"
NB_CORES=$(grep -c '^processor' /proc/cpuinfo)
export MAKEFLAGS="-j$((NB_CORES+1)) -l${NB_CORES}"

if [ "$LINUX_ARCH" == "x86_64" ]; then

echo "Removing old PPAs ..."
apt-get update -qq > /dev/null
sudo apt-get install -qq -y ppa-purge > /dev/null
ppa-purge ppa:coolwanglu/pdf2htmlex || true
ppa-purge ppa:fontforge/fontforge || true

echo "Updating all Ubuntu software repository lists ..."
apt-get update -qq > /dev/null

dpkg --purge pdf2htmlex fontforge > /dev/null
apt-get autoremove -qq -y > /dev/null

echo "Installing basic dependencies ..."
apt-get install -qq -y ttfautohint build-essential python-pip gcc libgetopt++-dev pkg-config autoconf libtool shtool git default-jre > /dev/null
if [ ! -f "cmake-3.10.1-Linux-x86_64.sh" ]; then
  echo "Downloading cmake via source ..."
  wget https://cmake.org/files/v3.10/cmake-3.10.1-Linux-x86_64.sh
fi
sudo sh cmake-3.10.1-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir


echo "Installing Poppler ..."
apt-get install -qq -y libnss3-dev libopenjpeg-dev libjpeg-turbo8-dev libfontconfig1-dev libfontforge-dev poppler-data poppler-utils poppler-dbg > /dev/null
if [ ! -f "$POPPLER_NAME.tar.xz" ]; then
  echo "Downloading poppler via source ..."
  wget "$POPPLER_SOURCE"
fi
tar -xvf "$POPPLER_NAME.tar.xz"
cd "$POPPLER_NAME/"
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_XPDF_HEADERS=ON -DENABLE_LIBOPENJPEG=none
make
make install


echo "Installing fontforge libuninameslist ..."
cd "$HOME_PATH"
echo "cloning fontforge libuninameslist via source ..."
git clone --depth 1 https://github.com/fontforge/libuninameslist.git
cd libuninameslist
autoreconf -i
automake
./configure
make
make install

echo "Installing fontforge ..."
cd "$HOME_PATH"
apt-get install -qq -y packaging-dev python-dev libpango1.0-dev libglib2.0-dev libxml2-dev giflib-dbg libjpeg-dev libtiff-dev uthash-dev libspiro-dev > /dev/null
echo "cloning fontforge via source ..."
git clone --depth 1 "$FONTFORGE_SOURCE"
cd fontforge/
./bootstrap
./configure
make
make install
ldconfig

echo "Installing Pdf2htmlEx ..."
cd "$HOME_PATH"
git clone --depth 1 "$PDF2HTMLEX_SOURCE"
cd pdf2htmlEX/
cmake .
make
make install

echo 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

cd "$HOME_PATH" && rm -rf "$POPPLER_NAME.tar.xz"
cd "$HOME_PATH" && rm -rf "$POPPLER_NAME/"
cd "$HOME_PATH" && rm -rf "libuninameslist"
cd "$HOME_PATH" && rm -rf "fontforge"
cd "$HOME_PATH" && rm -rf "pdf2htmlEX"

else
echo "********************************************************************"
echo "This script currently doesn't supports $LINUX_ARCH Linux archtecture"
fi

echo "----------------------------------"
echo "Build Complete"
