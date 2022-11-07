FROM mppmu/julia-anaconda:ub20-jl18-ac3202205-cu113

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

ENV \
    PATH="/opt/hdf5/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/hdf5/lib:$LD_LIBRARY_PATH"

RUN provisioning/install-sw.sh hdf5-srcbuild 1.12.1 /opt/hdf5


# Install CLHep and Geant4:

COPY provisioning/install-sw-scripts/clhep-* provisioning/install-sw-scripts/geant4-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/geant4/bin:/opt/clhep/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/geant4/lib:/opt/clhep/lib:$LD_LIBRARY_PATH" \
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

# https://askubuntu.com/questions/1034313/ubuntu-18-4-libqt5core-so-5-cannot-open-shared-object-file-no-such-file-or-dir
RUN strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5

RUN true \
    && apt-get update && apt-get install -y \
        libexpat-dev libxerces-c-dev libz-dev \
        libxmu-dev libxi-dev \
        libglu1-mesa-dev libmotif-dev libglfw3-dev \
        qt5-default qtbase5-dev-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && provisioning/install-sw.sh clhep 2.4.1.0 /opt/clhep \
    && provisioning/install-sw.sh geant4 10.5.1 /opt/geant4

ENV \
    G4TENDLDATA="/opt/geant4/share/Geant4-10.5.1/data/G4TENDL1.3.2" \
    G4PARTICLEHPDATA="/opt/geant4/share/Geant4-10.5.1/data/G4TENDL1.3.2" \
    G4PROTONHPDATA="/opt/geant4/share/Geant4-10.5.1/data/G4TENDL1.3.2/Proton" \
    G4DEUTERONHPDATA="/opt/geant4/share/Geant4-10.5.1/data/G4TENDL1.3.2/Deuteron" \
    G4TRITONHPDATA="/opt/geant4/share/Geant4-10.5.1/data/G4TENDL1.3.2/Triton" \
    G4HE3HPDATA="/opt/geant4/share/Geant4-10.5.1/data/G4TENDL1.3.2/He3" \
    G4ALPHAHPDATA="/opt/geant4/share/Geant4-10.5.1/data/G4TENDL1.3.2/Alpha"

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
    && apt-get update && apt-get install -y \
        libsm-dev \
        libx11-dev libxext-dev libxft-dev libxpm-dev \
        libxrandr-dev libxinerama-dev libxcursor-dev \
        libjpeg-dev libpng-dev \
        libglu1-mesa-dev \
	libcfitsio-dev libzstd-dev pythia8-root-interface \
	libmysqlclient-dev libpq-dev libsqlite3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
	cfitsio-devel mysql-devel postgresql-devel sqlite-devel\
    && provisioning/install-sw.sh root 6.24.06 /opt/root

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
        uproot awkward0 uproot3 awkward uproot4 xxhash \
        hepunits particle \
        iminuit


# Install Xpra:

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        xpra python3-uinput python3-paramiko python3-websockify \
        pwgen apg \
        xterm mlterm rxvt-unicode \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install Snakemake and panoptes-ui
# (Temporary: Pin jinja2 to v3.0, >v3.1 causes trouble for Jupyter of Anaconda 2021.11.)

RUN true \
    && mamba install -y -c conda-forge -c bioconda \
        snakemake \
        sqlite flask humanfriendly marshmallow pytest requests sqlalchemy \
        jinja2=3.0 \
    && pip3 install panoptes-ui


# Install PyTorch:

# Need to use pip to make PyTorch uses system-wide CUDA libs:
RUN pip3 install \
    torch==1.12.1 \
    torchvision==0.13.1 \
    torchaudio==0.12.1 \
    --extra-index-url https://download.pytorch.org/whl/cu113


# Install JAX:

RUN pip3 install \
    --upgrade "jax[cuda]==0.3.17" "jaxlib[cuda]==0.3.15" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html


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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

    # linux-tools-common for perf


# Set container-specific SWMOD_HOSTSPEC:

ENV SWMOD_HOSTSPEC="linux-ubuntu-20.04-x86_64-470e63d7"


# Final steps

CMD /bin/bash
