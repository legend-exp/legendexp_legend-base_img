# Linux Base Container for the LEGEND Experiment

This repository contains the files necessary to generate a CentOS-7 based Docker image that contains a basic software stack for the LEGEND experiment. The generated image does contain not any LEGEND-specific simulation and data processing/analysis software, but is intended to provide the basis for container images that do, as well as for LEGEND software development in general.

The Docker image includes the following Software:

* Anaconda v2019.03 (Python 3.7)
* ArrayFire v3.6
* GitHub Atom
* CERN ROOT v6.16
* CUDA v10.1
* Geant4 v10.5 and CLHep
* HDF5 (thread-safe build)
* Julia v1.1
* MXNet
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

to make the NVIDIA driver available within the container (the command `nvidia-smi` should then become available in the container as well.)


## Use with Docker

If you have sufficient privileges on your local system to install and use Docker, you can also run the Docker image directly:

```shell
docker pull legendexp/legend-base:latest
docker run -it --name mylegendinstance legendexp/legend-base:latest
```

You will probably want to use additional `docker run` options like `-p 8888:8888` and `-v /home/dir:/home/dir`. You may want to familiarize yourself with Docker first.

When using Docker Desktop (for Windows or for Mac), files created in mounted volumes (`-v` option) will belong the user who started the container, as one would expect. The docker engine actually runs inside a lightweight virtual Linux system (this is mostly transparent to the user). Likewise, the container themselves are also a Linux systems, independent of the system's native OS. Docker Desktop automatically manages the Linux VM, and transfers files between the VM and Host OS [which can result in noticeable latency](https://docs.docker.com/docker-for-mac/osxfs-caching/).

On Linux, the situation is different: Docker runs natively - and this means that all files that a container creates in mounted volumes will belong to "root", even if a user's home directory was mounted. This is typically not in the interest of the user. It is possibly to change this behavior by using [user namespaces](https://docs.docker.com/engine/security/userns-remap/), which is an advanced use case. Most Linux users will find it more convenient to use Singularity (see above) instead of Docker (Singularity utilizes user namespaces by default).


### Installing Docker

* On Linux: Install the [Docker Community Edition (CE)](https://docs.docker.com/install/).
* On OS-X: Install [Docker for Mac](https://docs.docker.com/docker-for-mac/).
* On Windows: Install [Docker for Windows](https://docs.docker.com/docker-for-windows/).


### Docker usage examples

#### Running a JupyterLab server inside a Docker container

We'll want to do something like this:

* Connect the current terminal input/output to the container (`docker` command option `--it`)

* Bind directory "/home/user" inside the container to your home directory on the host machine (option `-v "$HOME":"/home/user"`).

* Bind directory "/root" inside the container to directory "legend-base" in your home on the host machine (option -v "$HOME/legend-base":"/root":delegated). Since "$HOME" is set to "/root" inside the container, this ensure that all files created in "$HOME" by the container (e.g. Jupyter configuration, Julia packages, etc.) end up in "legend-base", instead of messing up your home directory. We'll use the `delegated` [mount semantics](https://docs.docker.com/docker-for-mac/osxfs-caching/) to reduce latency.

* Start a Jupyter server on port 8888 and configure it to accept connections on any container network interface (command `jupyter lab --ip 0.0.0.0 --port 8888 --allow-root --no-browser`).

* Bind port 8888 inside the container to port 8888 on the host system (option `-p 8888:8888`), so Jupyter can be accessed from the host system.

* Automatically remove the container (option `--rm`) after exiting Jupyter. This will also remove all files created within the container's file system while it ran (but not those created within the mount points "/home/user" and "/root").

##### OS-X

Run

```shell
docker run -it --rm \
    -v "$HOME":"/home/user" \
    -v "$HOME/legend-base":"/root":delegated \
    -p 8888:8888 \
    legendexp/legend-base:latest \
    jupyter lab --ip 0.0.0.0 --port 8888 --allow-root --no-browser
```

Then point your web browser (on the host system) to "http://127.0.0.1:8888/?token=..." (the Jupyter server will display the current valid token during it's start sequence).


#### Running GUI/X11 applications with Docker and local X11-Server

Running X11/GUI applications in a Docker container, using a local X11 server (outside of the container) as the display, is non-trivial on any host OS platform, but possible.

##### OS-X

* Install XQuartz (https://www.xquartz.org/)

* Start XQuartz, and enable ["Allow connections from network clients"](https://blogs.oracle.com/oraclewebcentersuite/running-gui-applications-on-native-docker-containers-for-mac) in the XQuartz preferences ("Security" tab).

* Quite and restart XQuartz to activate the new security settings

In a terminal, run

```shell
xhost + 127.0.0.1 # allow X11 access from localhost

docker run -it --rm \
    -v "$HOME":"/home/user" \
    -v "$HOME/legend-base":"/root":delegated \
    -e DISPLAY=host.docker.internal:0 \
    legendexp/legend-base:latest
```

This will start a container with an interactive X11-enabled bash shell. You should now be able to run X11/GUI programs.
See the Jupyter example above for the meaning of the `-it`, `--rm` and `-v` options.

**Note:** Using `xhost + 127.0.0.1` is less than optimal from a security point of view! It is only barely acceptable on a single user system, and *must not* be used on a system with multiple users. Is may be possible to bind the ".Xauthority" from the host into the container instead, but at least on OS-X that also doesn't seem to work.


#### Running GUI/X11 applications with Docker and Xpra/HTML5

A fairly robust, but less performant alternative to using an X11 server *outside* of the container (see above) is to use an Xpra server with HTML5 support *inside* of the container. This allows access to X11/GUI applications running in the container with a web browser from outside of it.

##### OS-X

Run

```
docker run -it --rm \
    -v "$HOME":"/home/user" \
    -v "$HOME/legend-base":"/root":delegated \
    -p 14500:14500 \
    legendexp/legend-base:latest \
    xpra start --no-daemon --bind-tcp=0.0.0.0:14500 --start=mlterm
```

to start the Docker container with an Xpra server with an mlterm terminal window (that can be used to start other X11/GUI applications). Point a web browser on the host to ["http://127.0.0.1:14500"](http://127.0.0.1:14500).

**Note:** This will allow all users and programs on the machine running the Docker container access to all applications (including the initial terminal window) running under Xpra. Security-wise, this *must not* be used on a system with multiple users. You should enable [Xpra password authentication](https://xpra.org/trac/wiki/Clients/HTML5) if anyone but you could possibly connect to the Xpra server (and even on a single-user system it would be advisable to use a password).
