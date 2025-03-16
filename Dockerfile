FROM mppmu/julia-conda:ub22-jl111-mf-cu126

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

RUN true \
    && apt-get update && apt-get install -y \
        libsm-dev \
        libx11-dev libxext-dev libxft-dev libxpm-dev \
        libxrandr-dev libxinerama-dev libxcursor-dev \
        libjpeg-dev libpng-dev \
        libglu1-mesa-dev \
        libcfitsio-dev libzstd-dev \
        libmysqlclient-dev libpq-dev libsqlite3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && provisioning/install-sw.sh root 6.28.00 /usr/local \
# Required for ROOT Jupyter kernel
    && mamba install -y metakernel

# Make PyROOT visible
# Accessing ROOT via Cxx.jl requires RTTI
ENV \
    JUPYTER_PATH="$JUPYTER_PATH:/usr/local/etc/notebook" \
    CLING_STANDARD_PCH="none" \
    PYTHONPATH="$PYTHONPATH:/usr/local/lib" \
    ROOTSYS="/usr/local" \
    JULIA_CXX_RTTI="1"


# Install additional Science-related Python packages:

RUN mamba install -y \
    lz4 zstandard \
    tensorboard \
    ultranest \
    uproot awkward0 uproot3 awkward uproot4 xxhash \
    hepunits particle \
    iminuit \
    numba


# Install Xpra:

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        xpra python3-uinput python3-paramiko python3-websockify \
        pwgen apg \
        xterm mlterm rxvt-unicode \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install Snakemake and panoptes-ui
# (Temporary: Pin jinja2 to v3.0, >v3.1 causes trouble for Jupyter of Anaconda 2021.11.)

RUN true \
    && mamba install -c conda-forge -c bioconda -y \
        snakemake panoptes-ui \
        sqlite flask humanfriendly marshmallow pytest requests sqlalchemy \
        jinja2=3.0


# Install PyTorch:

# Need to use pip to make PyTorch uses system-wide CUDA libs:
RUN pip3 install --upgrade --index-url https://download.pytorch.org/whl/cu126 \
    torch~=2.6.0 \
    torchvision \
    torchaudio


# Install JAX:

RUN pip3 install --upgrade \
    "jax[cuda12]~=0.5.2"


# Install dcraw and ImageMagick

RUN apt-get update && apt-get install -y \
        imagemagick dcraw \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install device control development dependencies:

RUN apt-get update && apt-get install -y \
        snmp libsnmp-dev \
        libmodbus-dev \
        libusb-1.0-0-dev \
        gphoto2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && mamba install -y pyserial


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


# Final steps

CMD /bin/bash
