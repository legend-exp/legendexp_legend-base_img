FROM nvidia/cuda:8.0-cudnn5-devel-centos7
# FROM centos:7

USER root
WORKDIR /root

RUN yum install -y epel-release && yum install -y \
    \
    deltarpm \
    \
    less man-db \
    openssh-clients rsync \
    wget curl nettle \
    bzip2 pbzip2 \
    nano vim \
    \
    gcc-c++ gcc-gfortran make \
    autoconf automake libtool m4 \
    cmake \
    \
    patch tar \
    git \
    \
    libSM-devel \
    libX11-devel libXext-devel libXft-devel libXpm-devel \
    libjpeg-devel libpng-devel \
    mesa-libGLU-devel \
    \
    openssl openssl-devel \
    \
    expat-devel \
    xerces-c-devel \
    libXmu-devel \
    libXi-devel \
    libzip-devel \
    \
    python2-pip python2-devel \
    python-daemon \
    zeromq-devel \
    \
    fftw-devel \
    \
    && rpm -ihv https://arrayfire.s3.amazonaws.com/3.4.2/ArrayFire-no-gl-v3.4.2_Linux_x86_64.rpm \
    && yum clean all

RUN pip install --upgrade pip && pip install \
    arrow enum34 luigi subprocess32 \
    jupyter metakernel

ENV ROOTSYS="/opt/root"

ENV \
    PATH="/opt/julia/bin:/opt/geant4/bin:/opt/clhep/bin:/opt/root/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/julia/lib:/opt/geant4/lib64:/opt/clhep/lib:/opt/root/lib:/usr/local/lib:$LD_LIBRARY_PATH" \
    MANPATH="/opt/julia/share/man:/opt/root/man:$MANPATH" \
    PYTHONPATH="/opt/root/lib:$PYTHONPATH" \
    CMAKE_PREFIX_PATH="/opt/root;$CMAKE_PREFIX_PATH" \
    JUPYTER_PATH="/opt/root/etc/notebook:$JUPYTER_PATH" \
    \
    ROOTSYS="/opt/root" \
    \
    G4LEDATA="/opt/geant4/share/Geant4-9.6.4/data/G4EMLOW6.32" \
    G4LEVELGAMMADATA="/opt/geant4/share/Geant4-9.6.4/data/PhotonEvaporation2.3" \
    G4NEUTRONHPDATA="/opt/geant4/share/Geant4-9.6.4/data/G4NDL4.2" \
    G4NEUTRONXSDATA="/opt/geant4/share/Geant4-9.6.4/data/G4NEUTRONXS1.2" \
    G4PIIDATA="/opt/geant4/share/Geant4-9.6.4/data/G4PII1.3" \
    G4RADIOACTIVEDATA="/opt/geant4/share/Geant4-9.6.4/data/RadioactiveDecay3.6" \
    G4REALSURFACEDATA="/opt/geant4/share/Geant4-9.6.4/data/RealSurface1.0" \
    G4SAIDXSDATA="/opt/geant4/share/Geant4-9.6.4/data/G4SAIDDATA1.1" \
    \
    JULIA_HOME="/opt/julia/bin" \
    \
    SWMOD_HOSTSPEC=linux-centos-7-x86_64-0ead8bff

COPY provisioning /root/provisioning

RUN true \
    && provisioning/install-sw.sh root 6.06.08 /opt/root \
    && provisioning/install-sw.sh clhep 2.1.3.1 /opt/clhep \
    && provisioning/install-sw.sh geant4 9.6.4 /opt/geant4

RUN true \
    && provisioning/install-sw.sh julia 0.5.0 `pwd`/julia
    && provisioning/install-sw.sh julia-cxx oschulz/julia0.5-root `pwd`/julia/share/julia/site
    && provisioning/install-sw.sh julia-rjulia jpata/cxx `pwd`/julia

EXPOSE 8888

CMD /bin/bash
