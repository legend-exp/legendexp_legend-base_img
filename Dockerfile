FROM mppmu/julia-anaconda:julia12-anaconda3201907

# User and workdir settings:

USER root
WORKDIR /root


# Copy provisioning script(s):

COPY provisioning/install-sw.sh /root/provisioning/


# Install Developer Toolset 8 (for GCC 8):

RUN true \
    && yum install -y centos-release-scl \
    && yum install -y devtoolset-8


# Install CLHep and Geant4:

COPY provisioning/install-sw-scripts/clhep-* provisioning/install-sw-scripts/geant4-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/geant4/bin:/opt/clhep/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/geant4/lib64:/opt/clhep/lib:$LD_LIBRARY_PATH" \
    G4ABLADATA="/opt/geant4/share/Geant4-10.5.1/data/G4ABLA3.1" \
    G4ENSDFSTATEDATA="/opt/geant4/share/Geant4-10.5.1/data/G4ENSDFSTATE2.2" \
    G4INCLDATA="/opt/geant4/share/Geant4-10.5.1/data/G4INCL1.0" \
    G4LEDATA="/opt/geant4/share/Geant4-10.5.1/data/G4EMLOW7.7" \
    G4LEVELGAMMADATA="/opt/geant4/share/Geant4-10.5.1/data/PhotonEvaporation5.3" \
    G4NEUTRONHPDATA="/opt/geant4/share/Geant4-10.5.1/data/G4NDL4.5" \
    G4PARTICLEXSDATA="/opt/geant4/share/Geant4-10.5.1/data/G4PARTICLEXS1.1" \
    G4PIIDATA="/opt/geant4/share/Geant4-10.5.1/data/G4PII1.3" \
    G4RADIOACTIVEDATA="/opt/geant4/share/Geant4-10.5.1/data/RadioactiveDecay5.3" \
    G4REALSURFACEDATA="/opt/geant4/share/Geant4-10.5.1/data/RealSurface2.1.1" \
    G4SAIDXSDATA="/opt/geant4/share/Geant4-10.5.1/data/G4SAIDDATA2.0" \
    AllowForHeavyElements=1

RUN true \
    && yum install -y \
        expat-devel xerces-c-devel zlib-devel \
        libXmu-devel libXi-devel \
        mesa-libGLU-devel motif-devel mesa-libGLw qt-devel \
    && provisioning/install-sw.sh clhep 2.4.1.0 /opt/clhep \
    && provisioning/install-sw.sh geant4 10.5.1 /opt/geant4


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
        libXrandr-devel libXinerama-devel libXcursor-devel \
        libjpeg-devel libpng-devel \
        mesa-libGLU-devel \
    && provisioning/install-sw.sh root 6.18.04 /opt/root

# Required for ROOT Jupyter kernel:
RUN pip install metakernel  

# Accessing ROOT via Cxx.jl requires RTTI:
ENV JULIA_CXX_RTTI="1"


# Install additional Jupyter-related Python packages:

RUN true \
    && conda install -y -c conda-forge rise \
    && conda install -y -c conda-forge jupyter_contrib_nbextensions \
    && pip install bash_kernel && JUPYTER_DATA_DIR="/opt/anaconda3/share/jupyter" python -m bash_kernel.install


# Install additional Science-related Python packages:

RUN conda install -y -c conda-forge lz4 && pip install uproot


# Install Xpra:

COPY provisioning/winswitch.repo /etc/yum.repos.d/winswitch7.repo

RUN yum install -y \
    xpra python2-uinput python-paramiko python-websockify \
    pwgen apg \
    xterm rxvt-unicode st \
    https://download.opensuse.org/repositories/home:/rabin-io/CentOS_7/x86_64/mlterm-3.8.7-3.4.x86_64.rpm


# Install OpenSSH Server:

RUN true \
    && yum install -y openssh-server \
    && ssh-keygen -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key \
    && ssh-keygen -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
    && ssh-keygen -N "" -t ed25519 -f /etc/ssh/ssh_host_ed25519_key


# Install additional LEGEND software build dependencies:

RUN yum install -y \
    libcurl-devel \
    boost-devel


# Install dcraw

COPY provisioning/install-sw-scripts/dcraw-* provisioning/install-sw-scripts/

ENV PATH="/opt/dcraw/bin:$PATH"

RUN true \
    && yum install -y libjpeg-turbo-devel jasper-devel lcms2-devel \
    && provisioning/install-sw.sh dcraw current /opt/dcraw


# Install device control development dependencies:

RUN yum install -y \
        net-snmp-devel net-snmp-utils \
        libmodbus-devel \
        libusbx-devel \
    && yum install -y http://springdale.math.ias.edu/data/puias/unsupported/7/x86_64//gphoto2-2.5.15-1.sdl7.x86_64.rpm \
    && conda install -y pyserial


# Install additional packages and clean up:

RUN yum install -y \
        \
        numactl \
        htop nmon \
        nano vim \
        git-gui gitk \
        valgrind \
        nmap-ncat \
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

ENV SWMOD_HOSTSPEC="linux-centos-7-x86_64-fab953d4"


# Final steps

CMD /bin/bash
