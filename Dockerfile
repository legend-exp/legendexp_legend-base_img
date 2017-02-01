FROM nvidia/cuda:8.0-cudnn5-devel-centos7
# FROM centos:7


# User and workdir settings:

USER root
WORKDIR /root


# Install yum/RPM packages:

COPY provisioning/wandisco-centos7-git.repo /etc/yum.repos.d/wandisco-git.repo

RUN true \
    && sed -i '/tsflags=nodocs/d' /etc/yum.conf \
    && yum install -y \
        epel-release \
    && yum groupinstall -y "Development Tools" \
    && yum install -y \
        deltarpm \
        \
        wget \
        cmake \
        p7zip pbzip2 \
        nano vim \
    && dbus-uuidgen > /etc/machine-id


# Copy provisioning script(s):

COPY provisioning/install-sw.sh /root/provisioning/


# Add CUDA libraries to LD_LIBRARY_PATH:

ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda/nvvm/lib64:$LD_LIBRARY_PATH"

# Install NVIDIA libcuda and create driver mount directories:

COPY provisioning/install-sw-scripts/nvidia-* provisioning/install-sw-scripts/

RUN true \
    && mkdir -p /usr/local/nvidia /etc/OpenCL/vendors \
    && provisioning/install-sw.sh nvidia-libcuda 375.26 /usr/lib64

# Note: Installed libcuda.so.1 only acts as a kind of stub. To run GPU code,
# NVIDIA driver libs must be mounted in from host to "/usr/local/nvidia"
# (e.g. via nvidia-docker or manually). OpenCL icd directory
# "/etc/OpenCL/vendors" should be mounted in from host as well.


# Install ArrayFire:

RUN true \
    && rpm -ihv "https://arrayfire.s3.amazonaws.com/3.4.2/ArrayFire-no-gl-v3.4.2_Linux_x86_64.rpm" \
    && (cd /usr/lib64 && ln -s ../lib/libaf*.so* .)


# Install CLHep and Geant4:

COPY provisioning/install-sw-scripts/clhep-* provisioning/install-sw-scripts/geant4-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/geant4/bin:/opt/clhep/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/geant4/lib64:/opt/clhep/lib:$LD_LIBRARY_PATH" \
    G4LEDATA="/opt/geant4/share/Geant4-9.6.4/data/G4EMLOW6.32" \
    G4LEVELGAMMADATA="/opt/geant4/share/Geant4-9.6.4/data/PhotonEvaporation2.3" \
    G4NEUTRONHPDATA="/opt/geant4/share/Geant4-9.6.4/data/G4NDL4.2" \
    G4NEUTRONXSDATA="/opt/geant4/share/Geant4-9.6.4/data/G4NEUTRONXS1.2" \
    G4PIIDATA="/opt/geant4/share/Geant4-9.6.4/data/G4PII1.3" \
    G4RADIOACTIVEDATA="/opt/geant4/share/Geant4-9.6.4/data/RadioactiveDecay3.6" \
    G4REALSURFACEDATA="/opt/geant4/share/Geant4-9.6.4/data/RealSurface1.0" \
    G4SAIDXSDATA="/opt/geant4/share/Geant4-9.6.4/data/G4SAIDDATA1.1"

RUN true \
    && yum install -y \
        expat-devel xerces-c-devel \
        libXmu-devel libXi-devel \
        libzip-devel \
        mesa-libGLU-devel \
    && provisioning/install-sw.sh clhep 2.1.3.1 /opt/clhep \
    && provisioning/install-sw.sh geant4 9.6.4 /opt/geant4


# Install CERN ROOT:

COPY provisioning/install-sw-scripts/root-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/root/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/root/lib:$LD_LIBRARY_PATH" \
    MANPATH="/opt/root/man:$MANPATH" \
    PYTHONPATH="/opt/root/lib:$PYTHONPATH" \
    CMAKE_PREFIX_PATH="/opt/root;$CMAKE_PREFIX_PATH" \
    JUPYTER_PATH="/opt/root/etc/notebook:$JUPYTER_PATH" \
    \
    ROOTSYS="/opt/root"

RUN true \
    && yum install -y \
        libSM-devel \
        libX11-devel libXext-devel libXft-devel libXpm-devel \
        libjpeg-devel libpng-devel \
        mesa-libGLU-devel \
    && provisioning/install-sw.sh root 6.06.08 /opt/root


# Install MXNet:

COPY provisioning/install-sw-scripts/mxnet-* provisioning/install-sw-scripts/

ENV \
    LD_LIBRARY_PATH="/opt/mxnet/lib:$LD_LIBRARY_PATH" \
    MXNET_HOME="/opt/mxnet"

RUN true \
    && yum install -y \
        openblas-devel \
        opencv-devel \
    && provisioning/install-sw.sh mxnet dmlc/873b928 /opt/mxnet


# Install Anaconda2:

COPY provisioning/install-sw-scripts/anaconda2-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/anaconda2/bin:$PATH" \
    MANPATH="/opt/anaconda2/share/man:$MANPATH"

RUN true \
    && yum install -y \
        libXdmcp \
    && provisioning/install-sw.sh anaconda2 4.2.0 /opt/anaconda2 \
    && conda upgrade -y pip notebook pexpect \
    && pip install --upgrade jupyterlab metakernel

EXPOSE 8888


# Install Julia:

COPY provisioning/install-sw-scripts/julia-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/julia/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/julia/lib:$LD_LIBRARY_PATH" \
    MANPATH="/opt/julia/share/man:$MANPATH" \
    JULIA_HOME="/opt/julia/bin" \
    JULIA_CXX_RTTI="1"

RUN true \
    && yum install -y \
        libedit-devel ncurses-devel openssl openssl-devel \
        hdf5-devel ImageMagick zeromq-devel gtk2 gtk3 \
    && provisioning/install-sw.sh julia 0.5.0 /opt/julia \
    && provisioning/install-sw.sh julia-cxx oschulz/julia0.5-root /opt/julia/share/julia/site \
    && provisioning/install-sw.sh julia-rjulia jpata/cxx /opt/julia


# Install GitHub Atom:

RUN yum install -y \
        lsb-core-noarch libXScrnSaver libXss.so.1 gtk3 libXtst libxkbfile GConf2 alsa-lib \
        levien-inconsolata-fonts dejavu-sans-fonts \
    && rpm -ihv https://github.com/atom/atom/releases/download/v1.13.0/atom.x86_64.rpm


# Install additional packages and clean up:

RUN yum install -y \
        numactl \
        readline-devel fftw-devel \
        graphviz-devel \
        \
        http://linuxsoft.cern.ch/cern/centos/7/cern/x86_64/Packages/parallel-20150522-1.el7.cern.noarch.rpm \
    && yum clean all


# Environment variables for swmod and "/user":

ENV \
    SWMOD_HOSTSPEC="linux-centos-7-x86_64-aec2b2b4" \
    SWMOD_INST_BASE="/user/.local/sw" \
    SWMOD_MODPATH="/user/.local/sw" \
    \
    PATH="/user/.local/bin:$PATH" \
    LD_LIBRARY_PATH="/user/.local/lib:$LD_LIBRARY_PATH" \
    MANPATH="/user/.local/share/man:$MANPATH" \
    PKG_CONFIG_PATH="/user/.local/lib/pkgconfig:$PKG_CONFIG_PATH" \
    CPATH="/user/.local/include:$CPATH" \
    PYTHONUSERBASE="/user/.local" \
    PYTHONPATH="/user/.local/lib/python2.7/site-packages:$PYTHONPATH"


# Final steps

CMD /bin/bash
