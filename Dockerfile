FROM ubuntu:16.04
MAINTAINER Ali Diouri <alidiouri@gmail.com>

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# install depdencies
RUN apt-get -qq update                                   &&  \
    DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade > _tmp   &&       \
    DEBIAN_FRONTEND=noninteractive apt-get -qq install                   \
        git                                                              \
        make                                                             \
        build-essential                                                  \
        g++                                                              \
        lib32gcc1                                                        \
        nano                                                             \
        libc6-i386                                                       \
        python                                                           \
        python2.7                                                        \
        unzip                                                            \
        wget                                                             \
        "^libxcb.*"                                                      \
        libx11-xcb-dev                                                   \
        libglu1-mesa-dev                                                 \
        libxrender-dev                                                   \
        libxi-dev                                                        \
        libssl-dev                                                       \
        libxcursor-dev                                                   \
        libxcomposite-dev                                                \
        libxdamage-dev                                                   \
        libxrandr-dev                                                    \
        libfontconfig1-dev                                               \
        libcap-dev                                                       \
        libbz2-dev                                                       \
        libgcrypt11-dev                                                  \
        libpci-dev                                                       \
        libnss3-dev                                                      \
        libxcursor-dev                                                   \
        libxcomposite-dev                                                \
        libxdamage-dev                                                   \
        libxrandr-dev                                                    \
        libdrm-dev                                                       \
        libfontconfig1-dev                                               \
        libxtst-dev                                                      \
        libasound2-dev                                                   \
        gperf                                                            \
        libcups2-dev                                                     \
        libpulse-dev                                                     \
        libudev-dev                                                      \
        libssl-dev                                                       \
        flex                                                             \
        bison                                                            \
        ruby                                                             \
        libicu-dev                                                       \
        libxslt-dev                                                      \
        zlib1g-dev > _tmp &&                                             \
    apt clean && rm _tmp

# Go to opt
WORKDIR /opt   

#******************************
#  NaCl SDK
#******************************
RUN wget http://storage.googleapis.com/nativeclient-mirror/nacl/nacl_sdk/nacl_sdk.zip  && \
    unzip ./nacl_sdk.zip && \
    rm nacl_sdk.zip && \
    nacl_sdk/naclsdk update pepper_47
ENV NACL_SDK_ROOT=/opt/nacl_sdk/pepper_47

WORKDIR /opt
ADD  qtxmlpatterns.patch /opt

# Checkout Qt 5.6
RUN git clone git://code.qt.io/qt/qt5.git Qt5.6
WORKDIR /opt/Qt5.6
RUN git checkout 5.6

RUN git submodule init
RUN git submodule update --remote qtbase && cd /opt/Qt5.6/qtbase && git checkout wip/nacl && cd ..
RUN git submodule update --remote qtdeclarative && cd /opt/Qt5.6/qtdeclarative && git checkout wip/nacl && cd ..
RUN git submodule update --remote qtxmlpatterns && cd /opt/Qt5.6/qtxmlpatterns && git checkout 5.6 && git apply ../../qtxmlpatterns.patch && cd ..
RUN git submodule update --remote qtsvg && cd /opt/Qt5.6/qtsvg && git checkout 5.6 && cd ..
RUN git submodule update --remote qtgraphicaleffects && cd /opt/Qt5.6/qtgraphicaleffects && git checkout 5.6 && cd ..
RUN git submodule update --remote qtquickcontrols && cd /opt/Qt5.6/qtquickcontrols && git checkout 5.6 && cd ..

WORKDIR /opt

RUN mkdir /opt/QtNaCl_56
WORKDIR /opt/QtNaCl_56
RUN bash -c " NACL_SDK_ROOT=/opt/nacl_sdk/$(find /opt/nacl_sdk -maxdepth 1 -type d -printf "%f\n" | grep 'pepper')  /opt/Qt5.6/qtbase/nacl-configure linux_x86_newlib release 64 -v -release -nomake examples -nomake tests -nomake tools"

# Compiling modules
RUN make module-qtbase -j6 > /root/module-qtbase.compile
RUN make module-qtdeclarative -j6 > /root/module-qtdeclarative.compile
RUN make module-qtquickcontrols -j6 > /root/module-qtquickcontrols.compile

# Adding Qt to the environement variables
ENV PATH=$PATH:/opt/QtNaCl_56/qtbase/bin:/opt/QtNaCl_56/qtbase/lib

# Cleaning
WORKDIR /opt/
RUN rm /opt/qtxmlpatterns.patch

WORKDIR /home/root

EXPOSE 8000

CMD ["/bin/bash"]
