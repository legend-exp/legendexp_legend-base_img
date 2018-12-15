# Linux Base Container for the LEGEND Experiment

This repository contains the files necessary to generate a CentOS-7 based Docker image that contains a basic software stack for the LEGEND experiment. The generated image does contain not any LEGEND-specific simulation and data processing/analysis software, but is intended to provide the basis for container images that do, as well as for LEGEND software development in general.

The Docker image includes the following Software:

* Anaconda v5.2 (Python 3.7)
* ArrayFire v3.6
* GitHub Atom v1.33
* CERN ROOT v6.14
* CUDA v10.0
* Geant4 v10.5 and CLHep
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


## Use with Docker

If you have sufficient privileges on your local system to install and use Docker, you can also run the Docker image directly:

```shell
docker pull legendexp/legend-base:latest
docker run -it --name mylegendinstance legendexp/legend-base:latest
```

You will probably want to use additional `docker run` options like `-p 8888:8888` and `-v /home/dir:/home/dir`. You may want to familiarize yourself with Docker first.


### Installing Docker

* On Linux: Install the [Docker Community Edition (CE)](https://docs.docker.com/install/)
* On OS-X: Install [Docker for Mac](https://docs.docker.com/docker-for-mac/)
* On Windows: Install [Docker for Windows](https://docs.docker.com/docker-for-windows/)

On OS-X and Windows, Docker will runs container instances in a lightweight virtual Linux system (this is mostly transparent to the user). Likewise, the container instance itself is always a Linux system, independent of the system's native OS.
