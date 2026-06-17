FROM mppmu/julia-python:ub24-jl112-pixi-cu128

# User and workdir settings:

USER root
WORKDIR /root


# Copy provisioning script(s):

COPY provisioning/install-sw.sh /root/provisioning/


# Install additional Science-related Python packages:

RUN cd "$PIXI_GLOBALPRJ" \
    && pixi add \
        lz4 zstandard \
        tensorboard \
        ultranest \
        uproot awkward0 uproot3 awkward uproot4 xxhash \
        hepunits particle \
        iminuit \
    && pixi add --pypi \
        hist[plot]


# Install Snakemake and panoptes-ui

RUN true \
    && cd "$PIXI_GLOBALPRJ" && pixi add \
        snakemake panoptes-ui \
        sqlite flask humanfriendly marshmallow pytest requests sqlalchemy \
        jinja2


# Install PyTorch:

RUN cd "$PIXI_GLOBALPRJ" && pixi add --pypi \
    torch~=2.10.0 \
    torchvision \
    torchaudio


# Install JAX:

RUN cd "$PIXI_GLOBALPRJ" && pixi add --pypi \
    "jax[cuda12-local]~=0.10.1"


# Install additional packages and clean up:

RUN apt-get update && apt-get install -y \
        linux-tools-common \
        uuid-runtime \
        \
        pbzip2 zstd\
        \
        poppler-utils \
        pre-commit \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

    # linux-tools-common for perf


# Set container-specific SWMOD_HOSTSPEC:

ENV SWMOD_HOSTSPEC="linux-ubuntu-24.04-x86_64-0a4a1dfc"


# Final steps

CMD /bin/bash
