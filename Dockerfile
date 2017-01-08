FROM nvidia/cuda:8.0-cudnn5-devel-centos7
# FROM centos:7


# User and workdir settings:

USER root
WORKDIR /root


# Add CUDA libraries to LD_LIBRARY_PATH:

ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:/usr/local/cuda/nvvm/lib64:$LD_LIBRARY_PATH"

# Note: NVIDIA driver libs must be mounted in from host to "/usr/local/nvidia"
# (e.g. via nvidia-docker or manually). OpenCL icd directory
# "/etc/OpenCL/vendors" should be mounted in from host as well.


# Install yum/RPM packages:

COPY provisioning/wandisco-centos7-git.repo /etc/yum.repos.d/wandisco-git.repo

RUN yum install -y epel-release centos-release-scl && yum install -y \
    \
    deltarpm \
    \
    less man-db \
    openssh-clients rsync \
    wget curl nettle \
    bzip2 pbzip2 zip unzip p7zip \
    nano vim \
    \
    gcc-c++ gcc-gfortran make \
    autoconf automake libtool m4 \
    cmake \
    \
    patch tar \
    git \
    \
    python2-pip python2-devel \
    python-daemon \
    zeromq-devel \
    \
    openblas-devel \
    opencv-devel \
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
    fftw-devel \
    \
    && mkdir -p /etc/OpenCL/vendors \
    \
    && rpm -ihv https://arrayfire.s3.amazonaws.com/3.4.2/ArrayFire-no-gl-v3.4.2_Linux_x86_64.rpm \
    && (cd /usr/lib64 && ln -s ../lib/libaf*.so* .) \
    \
    && yum clean all


# Install extra Python packages via pip:

RUN pip install --upgrade pip && pip install \
    jupyter jupyterlab metakernel \
    numpy \
    matplotlib \
    sympy


# Copy provisioning script(s):

COPY provisioning/install-sw.sh /root/provisioning/


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

RUN provisioning/install-sw.sh root 6.06.08 /opt/root


# Install MXNet:

COPY provisioning/install-sw-scripts/mxnet-* provisioning/install-sw-scripts/

ENV \
    LD_LIBRARY_PATH="/opt/mxnet/lib:$LD_LIBRARY_PATH" \
    MXNET_HOME="/opt/mxnet"

RUN provisioning/install-sw.sh mxnet dmlc/873b928 /opt/mxnet


# Install Julia:

COPY provisioning/install-sw-scripts/julia-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/julia/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/julia/lib:$LD_LIBRARY_PATH" \
    MANPATH="/opt/julia/share/man:$MANPATH" \
    JULIA_HOME="/opt/julia/bin" \
    JULIA_CXX_RTTI="1"

RUN true \
    && provisioning/install-sw.sh julia 0.5.0 /opt/julia \
    && provisioning/install-sw.sh julia-cxx oschulz/julia0.5-root /opt/julia/share/julia/site \
    && provisioning/install-sw.sh julia-rjulia jpata/cxx /opt/julia


# Additional packages: #!!! Move up

RUN sed -i '/tsflags=nodocs/d' /etc/yum.conf
RUN yum install -y nmap-ncat socat hdf5-devel && yum clean all


# Custom hostspec for swmod:

ENV SWMOD_HOSTSPEC=linux-centos-7-x86_64-0ead8bff


# Additional for Julia: #!!! Move up

ENV JULIA_PKGDIR="/user/.julia/$SWMOD_HOSTSPEC"
RUN mkdir -p "$JULIA_PKGDIR"


# Final steps

EXPOSE 8888

CMD /bin/bash
