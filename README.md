# Linux Base Container for the LEGEND Experiment

This repository contains the files necessary to generate a CentOS-7 based Docker image that contains a basic software stack for the LEGEND experiment. The generated image does contain not any LEGEND-specific simulation and data processing/analysis software, but is intended to provide the basis for container images that do, as well as for LEGEND software development in general.

The Docker image includes the following Software:

* Anaconda (Python v2.7)
* ArrayFire v3.6
* CERN ROOT v6.14
* CUDA v9.2
* Geant4 v10.4 and CLHep
* HDF5 (thread-safe build)
* Julia v1.0
* MXNet v1.3
* Node.js

Builds of this image are available on [Dockerhub](https://hub.docker.com/r/legendexp/legend-base/).


## Use with [NERSC Shifter](https://docs.nersc.gov/development/shifter/how-to-use/)


Pull the image via

    shifterimg pull docker:legendexp/legend-base:latest

Then try running an interactive session via

    shifter --image docker:legendexp/legend-base:latest -- /bin/bash


## Use with [Singularity](https://www.sylabs.io/singularity/)


With Singularity v2.x, convert the Docker image to a Singularity image via

    sudo singularity build legend-base.sqsh docker://legendexp/legend-base:latest

With Singularity v3.x, you'll probably want to use the new SIF container format:

    sudo singularity build legend-base.sif docker://legendexp/legend-base:latest

The resulting Singularity image file is quite large. On shared computing environments, the image file is best placed on a shared network/cluster file system (not in your home directory).

Afterwards, try running an interactive session via

    singularity shell /path/to/legend-base.[sqsh|sif]

On systems with NVIDIA GPUs, use

    singularity shell --nv /path/to/legend-base.[sqsh|sif]

to make the NVIDIA driver available within the container instance (the command `nvidia-smi` should then become available in the container instance as well.)
