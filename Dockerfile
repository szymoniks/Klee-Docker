############################################################
# Dockerfile to build Python WSGI Application Containers
# Based on Ubuntu
#
# To build the image run:
# sudo docker build -t klee_test .
############################################################


# Set the base image to Ubuntu
FROM ubuntu:14.04

# File Author / Maintainer
MAINTAINER Szymon Makula

##################################################################################
# General setup

RUN sudo apt-get update

# Install KLEE dependices
RUN sudo apt-get install -y  g++ \ 
                             curl \
                             dejagnu \
                             subversion \
                             bison \
                             flex \
                             bc \
                             libcap-dev \
                             make \
                             m4 \
                             autoconf \
                             automake1.4 \
                             python \
                             patch \
                             groff \
                             git \
                             ncurses-dev


ENV C_INCLUDE_PATH /usr/include/x86_64-linux-gnu
ENV CPLUS_INCLUDE_PATH /usr/include/x86_64-linux-gnu

# Solves Klee compiling issues - http://stackoverflow.com/questions/6329887/compiling-problems-cannot-find-crt1-o

RUN sudo ln -s /usr/lib/x86_64-linux-gnu /usr/lib64



##################################################################################
# LLVM-GCC 2.9

WORKDIR /home

# Download LLVM-GCC 2.9

RUN sudo curl http://llvm.org/releases/2.9/llvm-gcc4.2-2.9-x86_64-linux.tar.bz2 > llvm-gcc.tar.bz2

# Install LLVM-GCC 2.9

RUN tar jxf llvm-gcc.tar.bz2

ENV PATH $PATH:/home/llvm-gcc4.2-2.9-x86_64-linux/bin


##################################################################################
# LLVM 2.9

WORKDIR /home

# Patch - http://www.mail-archive.com/klee-dev@imperial.ac.uk/msg01302.html
ADD unistd-llvm-2.9-jit.patch /home/

# Download LLVM 2.9

RUN sudo curl http://llvm.org/releases/2.9/llvm-2.9.tgz > llvm-2.9.tgz

# Unpack LLVM 2.9

RUN tar zxf llvm-2.9.tgz

# Patch LLVM 2.9
RUN patch -p0 < /home/unistd-llvm-2.9-jit.patch

# Compile & install LLVM 2.9

WORKDIR llvm-2.9

RUN ./configure --enable-optimized --enable-assertions
RUN make -j5
RUN make -j5 install

ENV PATH $PATH:/home/llvm-2.9/tools


##################################################################################
# STP r940

WORKDIR /home

# Patch - https://github.com/stp/stp/commit/ece1a55fb367bd905078baca38476e35b4df06c3
ADD stp-fix.patch /home/

# Download STP

RUN sudo curl http://www.doc.ic.ac.uk/~cristic/klee/stp-r940.tgz > stp-r940.tgz

# Unpack STP

RUN tar xf stp-r940.tgz

WORKDIR stp-r940

# Patch STP
RUN patch -p0 < /home/stp-fix.patch

RUN ./scripts/configure --with-prefix=`pwd`/install --with-cryptominisat2  
RUN make -j5 OPTIMIZE=-O2 CFLAGS_M32= install

RUN ulimit -s unlimited

##################################################################################
# uclibc

WORKDIR /home

# Optional install uclibc 
# By default, KLEE works on closed programs (programs that don’t use any external code such as C library functions).

RUN git clone https://github.com/klee/klee-uclibc.git
WORKDIR klee-uclibc

RUN ./configure --make-llvm-lib
RUN make -j5




##################################################################################
# KLEE

WORKDIR /home

# Finally download and install KLEE

RUN git clone https://github.com/klee/klee.git

WORKDIR klee

RUN ./configure --with-llvm=/home/llvm-2.9 --with-stp=/home/stp-r940/install --with-uclibc=/home/klee-uclibc --enable-posix-runtime
RUN make -j5 ENABLE_OPTIMIZED=1
RUN make -j5 check
RUN make -j5 unittests
RUN make -j5 install

ENV PATH $PATH:/home/klee/tools
