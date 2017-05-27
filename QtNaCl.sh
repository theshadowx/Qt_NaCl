#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXEC_FOLDER=$(pwd)

echo ${SCRIPT_DIR}
echo ${EXEC_FOLDER}


# Install NaCl
wget http://storage.googleapis.com/nativeclient-mirror/nacl/nacl_sdk/nacl_sdk.zip
unzip nacl_sdk.zip
rm nacl_sdk.zip   
nacl_sdk/naclsdk list

# get the latest stable bender
nacl_sdk/naclsdk install pepper_47
NACL_SDK_ROOT=$(pwd)/$(find ./nacl_sdk -maxdepth 1 -type d -name "pepper*") 
echo "export NACL_SDK_ROOT=${NACL_SDK_ROOT}">> ~/.bashrc
source ~/.bashrc
echo ${NACL_SDK_ROOT}
echo "*******************************************************************************"


# Checkout Qt 5.6.0

git clone git://code.qt.io/qt/qt5.git Qt5.6
cd Qt5.6
git checkout 5.6
perl init-repository
git checkout 5.6

cd ${EXEC_FOLDER}/Qt5.6/qtbase
git checkout wip/nacl

cd ${EXEC_FOLDER}/Qt5.6/qtdeclarative
git checkout wip/nacl

cd ${EXEC_FOLDER}/Qt5.6/qtxmlpatterns
git apply ${SCRIPT_DIR}/qtxmlpatterns.patch
cd ${EXEC_FOLDER}

mkdir QtNaCl_56
cd QtNaCl_56
NACL_SDK_ROOT=$(find ${EXEC_FOLDER}/nacl_sdk -maxdepth 1 -type d -name "pepper*") ${EXEC_FOLDER}/Qt5.6/qtbase/nacl-configure linux_x86_newlib release 64

make module-qtbase -j6 > module-qtbase.log
make module-qtdeclarative -j6 > module-qtdeclarative.log
make module-qtquickcontrols -j6 > module-qtquickcontrols.log

#running the example
# cd ../Qt5.4.2/qtdeclarative/examples/nacl
# mkdir build
# cd build
# ../../../../../QtNacl_5.4/qtbase/bin/qmake ..
# make
# ../../../../../QtNacl_5.4/qtbase/bin/nacldeployqt nacl.nexe --run
