#!/bin/bash

set -e

# Install NaCl
wget http://storage.googleapis.com/nativeclient-mirror/nacl/nacl_sdk/nacl_sdk.zip
unzip nacl_sdk.zip
rm nacl_sdk.zip   
nacl_sdk/naclsdk list

# get the latest stable bender
nacl_sdk/naclsdk install pepper_47
NACL_SDK_ROOT=$(pwd)/$(find ./nacl_sdk -maxdepth 1 -type d -name "pepper*") 
echo "export NACL_SDK_ROOT=$NACL_SDK_ROOT">> ~/.bashrc
source ~/.bashrc

# Checkout Qt 5.6.0

git clone git://code.qt.io/qt/qt5.git Qt5.6
cd Qt5.6
git checkout 5.6
perl init-repository
git checkout 5.6
cd ..

cd Qt5.6/qtbase
git checkout wip/nacl

cd ../qtdeclarative
git checkout wip/nacl

cd ../qtxmlpatterns
git apply ../../qtxmlpatterns.patch
cd ../..

mkdir QtNaCl_56
cd QtNaCl_56
../Qt5.6/qtbase/nacl-configure linux_x86_newlib release 64

make module-qtbase -j6
make module-qtdeclarative -j6
make module-qtquickcontrols -j6

#running the example
# cd ../Qt5.4.2/qtdeclarative/examples/nacl
# mkdir build
# cd build
# ../../../../../QtNacl_5.4/qtbase/bin/qmake ..
# make
# ../../../../../QtNacl_5.4/qtbase/bin/nacldeployqt nacl.nexe --run
