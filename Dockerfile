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
        uproot awkward0 uproot3 awkward uproot4 xxhash \
        hepunits particle \
        iminuit \
    && pixi add --pypi \
        hist[plot]


# Install UltraNest:

# There is no conda-forge build of UltraNest for linux-aarch64, fall back to
# the PyPI source distribution on architectures that lack one:

RUN cd "$PIXI_GLOBALPRJ" \
    && if [ "`uname -m`" = "x86_64" ] ; then \
        pixi add ultranest ; \
    else \
        pixi add --pypi ultranest ; \
    fi


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

# The value of "ENV"s can't be computed during build, so architecture must
# be passed in as a build argument:
ARG BUILD_ARCH

RUN test "${BUILD_ARCH}" = "`uname -m`" || { \
        echo "ERROR: Build argument BUILD_ARCH=\"${BUILD_ARCH}\" doesn't match image architecture \"`uname -m`\", build the image via \"./build.sh\"." >&2 ; \
        exit 1 ; \
    }

ENV SWMOD_HOSTSPEC="linux-ubuntu-24.04-${BUILD_ARCH}-0a4a1dfc"


# Final steps

CMD /bin/bash
