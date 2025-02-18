FROM nvidia/cuda:8.0-cudnn5-devel-centos7
# FROM centos:7


# User and workdir settings:

USER root
WORKDIR /root


# Copy provisioning script(s):

COPY provisioning/install-sw.sh /root/provisioning/


# Install additional LEGEND software build dependencies:

RUN apt-get update && apt-get install -y \
        libcurl4-gnutls-dev \
        libboost-all-dev \
        libzmq3-dev \
        libfftw3-dev \
        libxml2-dev \
        libgsl-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install HDF5:

COPY provisioning/install-sw-scripts/hdf5-* provisioning/install-sw-scripts/

RUN provisioning/install-sw.sh hdf5-srcbuild 1.12.3 /usr/local


# Install CLHep and Geant4:

COPY provisioning/install-sw-scripts/clhep-* provisioning/install-sw-scripts/geant4-* provisioning/install-sw-scripts/

ENV \
    G4ABLADATA="/usr/local/share/Geant4-10.5.1/data/G4ABLA3.1" \
    G4ENSDFSTATEDATA="/usr/local/share/Geant4-10.5.1/data/G4ENSDFSTATE2.2" \
    G4INCLDATA="/usr/local/share/Geant4-10.5.1/data/G4INCL1.0" \
    G4LEDATA="/usr/local/share/Geant4-10.5.1/data/G4EMLOW7.7" \
    G4LEVELGAMMADATA="/usr/local/share/Geant4-10.5.1/data/PhotonEvaporation5.3" \
    G4NEUTRONHPDATA="/usr/local/share/Geant4-10.5.1/data/G4NDL4.5" \
    G4PARTICLEXSDATA="/usr/local/share/Geant4-10.5.1/data/G4PARTICLEXS1.1" \
    G4PIIDATA="/usr/local/share/Geant4-10.5.1/data/G4PII1.3" \
    G4RADIOACTIVEDATA="/usr/local/share/Geant4-10.5.1/data/RadioactiveDecay5.3" \
    G4REALSURFACEDATA="/usr/local/share/Geant4-10.5.1/data/RealSurface2.1.1" \
    G4SAIDXSDATA="/usr/local/share/Geant4-10.5.1/data/G4SAIDDATA2.0" \
    AllowForHeavyElements=1

RUN true \
    # https://askubuntu.com/questions/1034313/ubuntu-18-4-libqt5core-so-5-cannot-open-shared-object-file-no-such-file-or-dir
    && strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5 \
    && apt-get update && apt-get install -y \
        libexpat-dev libxerces-c-dev libz-dev \
        libxmu-dev libxi-dev \
        libglu1-mesa-dev libmotif-dev libglfw3-dev \
        qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && provisioning/install-sw.sh clhep 2.4.1.0 /usr/local \
    && provisioning/install-sw.sh geant4 10.5.1 /usr/local

ENV \
    G4TENDLDATA="/usr/local/share/Geant4-10.5.1/data/G4TENDL1.3.2" \
    G4PARTICLEHPDATA="/usr/local/share/Geant4-10.5.1/data/G4TENDL1.3.2" \
    G4PROTONHPDATA="/usr/local/share/Geant4-10.5.1/data/G4TENDL1.3.2/Proton" \
    G4DEUTERONHPDATA="/usr/local/share/Geant4-10.5.1/data/G4TENDL1.3.2/Deuteron" \
    G4TRITONHPDATA="/usr/local/share/Geant4-10.5.1/data/G4TENDL1.3.2/Triton" \
    G4HE3HPDATA="/usr/local/share/Geant4-10.5.1/data/G4TENDL1.3.2/He3" \
    G4ALPHAHPDATA="/usr/local/share/Geant4-10.5.1/data/G4TENDL1.3.2/Alpha"

RUN mkdir "$G4TENDLDATA" \
    && wget -O- "http://geant4-data.web.cern.ch/geant4-data/datasets/G4TENDL.1.3.2.tar.gz" \
        | tar --strip-components 1 -C "$G4TENDLDATA" --strip=1 -x -z


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
    && provisioning/install-sw.sh root 6.10.02 /opt/root


# Install MXNet:

COPY provisioning/install-sw-scripts/mxnet-* provisioning/install-sw-scripts/

ENV \
    LD_LIBRARY_PATH="/opt/mxnet/lib:$LD_LIBRARY_PATH" \
    MXNET_HOME="/opt/mxnet"

RUN true \
    && yum install -y \
        openblas-devel \
        opencv-devel \
    && provisioning/install-sw.sh mxnet dmlc/bbf1c0b /opt/mxnet


# Install Anaconda2:

COPY provisioning/install-sw-scripts/anaconda2-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/anaconda2/bin:$PATH" \
    MANPATH="/opt/anaconda2/share/man:$MANPATH" \
    JUPYTER=jupyter

    # JUPYTER environment variable used by IJulia to detect Jupyter installation

RUN true \
    && yum install -y \
        libXdmcp \
        texlive-collection-latexrecommended texlive-dvipng texlive-adjustbox texlive-upquote texlive-ulem \
    && provisioning/install-sw.sh anaconda2 4.4.0 /opt/anaconda2 \
    && conda install -c conda-forge nbpresent pandoc \
    && conda install -c anaconda-nb-extensions nbbrowserpdf \
    && conda install -c damianavila82 rise \
    && pip install jupyterlab metakernel bash_kernel \
    && JUPYTER_DATA_DIR="/opt/anaconda2/share/jupyter" python -m bash_kernel.install

EXPOSE 8888


# Install ArrayFire:

RUN true \
    && rpm -ihv "https://arrayfire.s3.amazonaws.com/3.5.0/ArrayFire-no-gl-v3.5.0_Linux_x86_64.rpm" \
    && (cd /usr/lib64 && ln -s ../lib/libaf*.so* .)


# Install Java:

RUN yum install -y \
        java-1.8.0-openjdk-devel


# Install HDF5:

COPY provisioning/install-sw-scripts/hdf5-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/hdf5/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/hdf5/lib:$LD_LIBRARY_PATH"

RUN provisioning/install-sw.sh hdf5-srcbuild 1.10.1 /opt/hdf5


# Install GitHub Atom:

RUN yum install -y \
        lsb-core-noarch libXScrnSaver libXss.so.1 gtk3 libXtst libxkbfile GConf2 alsa-lib \
        levien-inconsolata-fonts dejavu-sans-fonts libsecret \
    && rpm -ihv https://github.com/atom/atom/releases/download/v1.21.0/atom.x86_64.rpm



# Install development tools:
RUN yum install -y \
        valgrind


# Install device control development dependencies:
RUN yum install -y \
        net-snmp-devel net-snmp-utils \
        libmodbus-devel \
        libusbx-devel


# Install additional packages and clean up:

RUN apt-get update && apt-get install -y \
        valgrind linux-tools-common \
        uuid-runtime \
        \
        pbzip2 zstd libzstd-dev \
        \
        libreadline-dev \
        graphviz-dev \
        \
        poppler-utils \
        pre-commit \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

    # linux-tools-common for perf


# Set container-specific SWMOD_HOSTSPEC:

ENV SWMOD_HOSTSPEC="linux-ubuntu-22.04-x86_64-3f6848ed"
ENV SWMOD_HOSTSPEC="linux-centos-7-x86_64-aec2b2b4"


# Final steps

CMD /bin/bash
