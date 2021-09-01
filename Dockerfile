FROM mppmu/julia-anaconda:julia17-anaconda3202105

# User and workdir settings:

USER root
WORKDIR /root


# Copy provisioning script(s):

COPY provisioning/install-sw.sh /root/provisioning/


# Install Developer Toolset 8 (for GCC 8):

RUN true \
    && yum install -y centos-release-scl \
    && yum install -y devtoolset-8


# Install HDF5:

COPY provisioning/install-sw-scripts/hdf5-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/hdf5/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/hdf5/lib:$LD_LIBRARY_PATH"

RUN provisioning/install-sw.sh hdf5-srcbuild 1.12.1 /opt/hdf5


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

ENV G4TENDLDATA="/opt/geant4/share/Geant4-10.5.1/data/G4TENDL1.3.2"
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
        libXrandr-devel libXinerama-devel libXcursor-devel \
        libjpeg-devel libpng-devel \
        mesa-libGLU-devel \
    && provisioning/install-sw.sh root 6.24.04 /opt/root

# Required for ROOT Jupyter kernel:
RUN mamba install -y metakernel  

# Accessing ROOT via Cxx.jl requires RTTI:
ENV JULIA_CXX_RTTI="1"


# Install additional Science-related Python packages:

RUN true \
    && mamba install -y lz4 zstandard \
    && mamba install -y -c conda-forge \
        tensorboard \
        ultranest \
        uproot awkward uproot3 awkward0 uproot4 awkward1 xxhash \
        hepunits particle


# Install Xpra:

COPY provisioning/winswitch.repo /etc/yum.repos.d/winswitch7.repo

RUN yum install -y \
    xpra python2-uinput python-paramiko python-websockify \
    pwgen apg \
    xterm rxvt-unicode st \
    https://download.opensuse.org/repositories/home:/rabin-io/CentOS_7/x86_64/mlterm-3.9.0-8.3.x86_64.rpm


# Install additional LEGEND software build dependencies:

RUN yum install -y \
    libcurl-devel \
    boost-devel


# Install Snakemake and panoptes-ui

RUN true \
    && mamba install -y -c conda-forge -c bioconda \
        snakemake \
        sqlite flask humanfriendly marshmallow pytest requests sqlalchemy \
    && pip3 install panoptes-ui


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
    && mamba install -y pyserial


# Install additional packages and clean up:

RUN yum install -y \
        valgrind perf \
        \
        pbzip2 zstd libzstd-devel \
        \
        readline-devel \
        graphviz-devel \
        \
        poppler-utils \
    && yum clean all


# Set container-specific SWMOD_HOSTSPEC:

ENV SWMOD_HOSTSPEC="linux-centos-7-x86_64-fab953d4"


# Final steps

CMD /bin/bash
