FROM mppmu/cuda-julia-anaconda

# User and workdir settings:

USER root
WORKDIR /root


# Copy provisioning script(s):

COPY provisioning/install-sw.sh /root/provisioning/


# Install MXNet:

COPY provisioning/install-sw-scripts/mxnet-* provisioning/install-sw-scripts/

ENV \
    LD_LIBRARY_PATH="/opt/mxnet/lib:$LD_LIBRARY_PATH" \
    MXNET_HOME="/opt/mxnet"

RUN true \
    && yum install -y \
        openblas-devel \
        opencv-devel \
    && provisioning/install-sw.sh mxnet apache/1.1.0 /opt/mxnet


# Install CLHep and Geant4:

COPY provisioning/install-sw-scripts/clhep-* provisioning/install-sw-scripts/geant4-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/geant4/bin:/opt/clhep/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/geant4/lib64:/opt/clhep/lib:$LD_LIBRARY_PATH" \
    G4ABLADATA="/opt/geant4/share/Geant4-10.4.1/data/G4ABLA3.1" \
    G4ENSDFSTATEDATA="/opt/geant4/share/Geant4-10.4.1/data/G4ENSDFSTATE2.2" \
    G4LEDATA="/opt/geant4/share/Geant4-10.4.1/data/G4EMLOW7.3" \
    G4LEVELGAMMADATA="/opt/geant4/share/Geant4-10.4.1/data/PhotonEvaporation5.2" \
    G4NEUTRONHPDATA="/opt/geant4/share/Geant4-10.4.1/data/G4NDL4.5" \
    G4NEUTRONXSDATA="/opt/geant4/share/Geant4-10.4.1/data/G4NEUTRONXS1.4" \
    G4PIIDATA="/opt/geant4/share/Geant4-10.4.1/data/G4PII1.3" \
    G4RADIOACTIVEDATA="/opt/geant4/share/Geant4-10.4.1/data/RadioactiveDecay5.2" \
    G4REALSURFACEDATA="/opt/geant4/share/Geant4-10.4.1/data/RealSurface2.1" \
    G4SAIDXSDATA="/opt/geant4/share/Geant4-10.4.1/data/G4SAIDDATA1.1" \
    AllowForHeavyElements=1

RUN true \
    && yum install -y \
        expat-devel xerces-c-devel zlib-devel \
        libXmu-devel libXi-devel \
        mesa-libGLU-devel motif-devel mesa-libGLw qt-devel \
    && provisioning/install-sw.sh clhep 2.4.0.0 /opt/clhep \
    && provisioning/install-sw.sh geant4 10.4.1 /opt/geant4


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
    && provisioning/install-sw.sh root 6.12.06 /opt/root

# Required for ROOT Jupyter kernel:
RUN pip install metakernel  

# Accessing ROOT via Cxx.jl requires RTTI:
ENV JULIA_CXX_RTTI="1"


# Install ArrayFire:

RUN true \
    && rpm -ihv "https://arrayfire.s3.amazonaws.com/3.5.1/ArrayFire-no-gl-v3.5.1_Linux_x86_64.rpm" \
    && (cd /usr/lib64 && ln -s ../lib/libaf*.so* .)


# Install additional Python packages:

RUN true \
    && conda install -y -c anaconda-nb-extensions nbbrowserpdf \
    && conda install -y -c damianavila82 rise \
    && pip install bash_kernel && JUPYTER_DATA_DIR="/opt/anaconda2/share/jupyter" python -m bash_kernel.install


# Install Atom:

RUN yum install -y \
        lsb-core-noarch libXScrnSaver libXss.so.1 gtk3 libXtst libxkbfile GConf2 alsa-lib \
        levien-inconsolata-fonts dejavu-sans-fonts libsecret \
    && rpm -ihv https://github.com/atom/atom/releases/download/v1.26.0/atom.x86_64.rpm


# Install device control development dependencies:
RUN yum install -y \
        net-snmp-devel net-snmp-utils \
        libmodbus-devel \
        libusbx-devel


# Install Nvidia visual profiler:

RUN true \
    && yum install -y \
        cuda-nvvp-9-1


# Install additional packages and clean up:

RUN yum install -y \
        \
        numactl \
        nano vim \
        git-gui gitk \
        valgrind \
        \
        pbzip2 zstd libzstd-devel \
        \
        readline-devel \
        graphviz-devel \
        \
        poppler-utils \
        \
        http://linuxsoft.cern.ch/cern/centos/7/cern/x86_64/Packages/parallel-20150522-1.el7.cern.noarch.rpm \
    && yum clean all


# Set container-specific SWMOD_HOSTSPEC:

ENV SWMOD_HOSTSPEC="linux-centos-7-x86_64-aec2b2b4"


# Final steps

CMD /bin/bash
