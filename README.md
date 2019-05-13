# Linux Base Container for the LEGEND Experiment

This repository contains the files necessary to generate a CentOS-7 based Docker image that contains a basic software stack for the LEGEND experiment. The generated image does contain not any LEGEND-specific simulation and data processing/analysis software, but is intended to provide the basis for container images that do, as well as for LEGEND software development in general.

The Docker image includes the following Software:

* Anaconda v2019.03 (Python 3.7)
* GitHub Atom
* CERN ROOT v6.16
* Geant4 v10.5 and CLHep
* HDF5 (thread-safe build)
* Julia v1.1
* Node.js

Builds of this image are available on [Dockerhub](https://hub.docker.com/r/legendexp/legend-base/).

You can run instances of the image via Shifter (recommended for NERSC users), Singularity (recommended for non-NERSC Linux systems) or directly via Docker (on personal systems only, recommended for Mac OS-X and MS Windows users).


## Use with [NERSC Shifter](https://docs.nersc.gov/development/shifter/how-to-use/)


Pull the image via

    shifterimg pull docker:legendexp/legend-base:latest

Then try running an interactive session via

    shifter --image docker:legendexp/legend-base:latest -- /bin/bash


### Using Jupyter

You can [use Jupyter kernels in Shifter containers](https://docs.nersc.gov/services/jupyter/#shifter-kernels-on-jupyter) on NERSC's JupyterHub.


### Running GUI/X11 applications

When connected to NERSC via `ssh -X`, you can run X11/GUI applications inside (and outside) of Shifter containers. However, X11 over SSH can be slow, depending on your network bandwidth and latency to NERSC. Starting an Xpra server (see below in, but in contrast to Docker no network port binding is necessary) may be a good alternative.


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


### Using Jupyter

Jupyter is installed in the container image, you can simply run

```shell
    jupyter lab --no-browser
```

on a Singularity container shell.

Now point your web browser (outside of the container) to "http://127.0.0.1:8888/?token=..." (the Jupyter server will display the current valid token during it's start sequence).


### Running GUI/X11 applications

When using Singularity on a local system, you should be able to seamlessly run X11/GUI applications inside of containers. When using a remote system, starting an Xpra server (see below, but in contrast to Docker no network port binding is necessary) may be a good alternative to `ssh -X`.


## Use with [Docker](https://www.docker.com/)

If you have sufficient privileges on your local system to install and use Docker, you can also run the Docker image directly:

```shell
docker pull legendexp/legend-base:latest
docker run -it --name mylegendinstance legendexp/legend-base:latest
```

To load saved Docker image from a file, use `docker load` instead of `docker pull`:

```shell
docker load -i IMAGE_FILENAME.tar[.gz]
```

You will probably want to use additional `docker run` options like `-p PORT:PORT` and `-v /dir/outside:/dir/inside`. You may want to [familiarize yourself with Docker first](https://docs.docker.com/get-started/). In particular, you will want to understand the [`docker run`](https://docs.docker.com/engine/reference/run/), [`docker container ls`](https://docs.docker.com/engine/reference/commandline/container_ls/)/[`start`](https://docs.docker.com/engine/reference/commandline/container_start/)/[`stop`](https://docs.docker.com/engine/reference/commandline/container_stop/)/[`rm`](https://docs.docker.com/engine/reference/commandline/container_rm/), and [`docker image ls`](https://docs.docker.com/engine/reference/commandline/image_ls/)/[`rm`](https://docs.docker.com/engine/reference/commandline/image_rm/) commands.

If you run out of disk space and everything gets bonked, do something like:

```
# List all running and stopped containers:
docker container ls -a
# Kill all running containers:
docker container kill `docker container ls -q`
# Remove all stopped containers:
docker container prune
# List container images:
docker image ls [-a]
# Also remove all (dangling or all) images (and more):
docker system prune [-a]
```

When using Docker Desktop (for Windows or for Mac), files created in mounted volumes (`-v` option) will belong the user who started the container, as one would expect. The docker engine itself actually runs inside a lightweight virtual Linux system (this is mostly transparent to the user). Likewise, the containers themselves are also a Linux systems, independent of the host system's native OS. Docker Desktop automatically manages the Linux VM, and transfers files between the VM and Host OS [which can result in noticeable latency](https://docs.docker.com/docker-for-mac/osxfs-caching/).

On Linux, the situation is different: Docker runs natively and this means that all files that a container creates in mounted volumes will belong to "root", even if a user's home directory was mounted. This is typically not in the interest of the user. It is possibly to change this behavior by using [user namespaces](https://docs.docker.com/engine/security/userns-remap/), which is an advanced use case. Most Linux users will find it more convenient to use Singularity (see above) instead of Docker (Singularity utilizes user namespaces by default).


### Installing Docker

* On Linux: Install the [Docker Community Edition (CE)](https://docs.docker.com/install/).
* On OS-X: Install [Docker for Mac](https://docs.docker.com/docker-for-mac/).
* On Windows: Install [Docker for Windows](https://docs.docker.com/docker-for-windows/).


### Docker usage examples

#### Running Bash shell inside a Docker container

We want to:

* Connect the current terminal input/output to the container (`docker` command option `--it`)

* Bind directory `"/home/user"` inside the container to your home directory on the host machine (option `-v "$HOME":"/home/user"`).

* Bind directory `"/root"` inside the container to directory `"legend-base"` in your home on the host machine (option `-v "$HOME/legend-base":"/root":delegated`). Since `"$HOME"` is set to `"/root"` inside the container, this ensure that all files created in `"$HOME"` by the container (e.g. config files like Jupyter configuration, Julia packages, etc.) end up in `"legend-base"` on the host system, instead of messing up your home directory. We'll use the `delegated` [mount semantics](https://docs.docker.com/docker-for-mac/osxfs-caching/) to reduce latency.

* Bind port 8888 inside the container to port 8888 on the host system (option `-p 8888:8888`), so a Jupyter server running in the container (see below) can be accessed from the host system.

* Bind port 14500 inside the container to port 14500 on the host system, so an Xpra server running in the container (see below) can be accessed from the host system.

* Automatically remove the container (option `--rm`) after exiting it. This will also remove all files created within the container's file system while it ran (but not those created within the mount points "/home/user" and "/root").

We'll start a container running a Bash shell, which will have access to all software the container provides. Within the Docker container, you will be user "root". "$HOME" will point to `"/root"`, which is kept in sync, bi-directionally and in (almost) real time, to the directory "$HOME/legend-base" outside of the container (see above). Likewise, `"/home/user"` within the container will be kept in sync with `"$HOME"` outside of the container.


##### OS-X

Run

```shell
docker run -it --rm \
    -v "$HOME":"/home/user" \
    -v "$HOME/legend-base":"/root":delegated \
    -p 8888:8888 \
    -p 14500:14500 \
    legendexp/legend-base:latest
```

To start the container and run a different program than `bash` inside of it directly (not via the shell), use

```shell
docker run [...options...] legendexp/legend-base:latest PROGRAM_TO_RUN ARGS...
```


#### Running a JupyterLab server inside a Docker container

First, start a containerized shell (don't forget `docker` option `-p 8888:8888`). Then, from that shell, start a Jupyter server on port 8888 and configure it to accept connections on any container network interface:

```shell
# Within container:
jupyter lab --ip 0.0.0.0 --port 8888 --allow-root --no-browser
```

Now point your web browser (outside of the container) to "http://127.0.0.1:8888/?token=..." (the Jupyter server will display the current valid token during it's start sequence).

You can also use [password-based access](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html#automatic-password-setup) instead of token based access. To set a Jupyter password, run

```shell
# Within container:
jupyter notebook password
```


#### Running GUI/X11 applications with Docker and Xpra/HTML5

In contrast to Singularity, Docker does not allow for running X11/GUI applications in a container by default. It's possible (see below), but it will often be easier and more secure (though less performant on a local system) to run an Xpra server with HTML5 support within the container. This allows access to X11/GUI applications running in the container via a web browser from outside of of the container.

First, you should set an Xpra TCP password. Start a containerized shell as described above. Then, in that shell, run

```shell
# Within container:
export XPRA_CONF_FILENAME="$HOME/.xpra/xpra.conf"
mkdir "$HOME/.xpra" && chmod 700 "$HOME/.xpra"
xpra showconfig # will create "$HOME/.xpra/xpra.conf"
echo "tcp-auth=password:value=`pwgen -n1 10`" >> "$HOME/.xpra/xpra.conf"
xpra showconfig
```

and exit the containerized shell. Check the output of `xpra config` to look up the password.
Open the the Xpra config file with `nano -w "$HOME/.xpra/xpra.conf"` change the password.

Now, again in a containerized shell (don't forget `docker` option `-p 14500:14500`), run

```shell
# Within container:
export XPRA_CONF_FILENAME="$HOME/.xpra/xpra.conf"
xpra start --no-daemon --bind-tcp=0.0.0.0:14500 --html=on --start=mlterm
```

to start your personal password-secured Xpra server. Point your web browser on the host to ["http://127.0.0.1:14500"](http://127.0.0.1:14500). You should see a web page titled "Xpra HTML5 Client". Enter the password (leave the user name field empty) and click on "Connect". You should then get an mlterm terminal window within your browser window - other X11/GUI applications can now be started using that terminal.

This procedure can also be used to run graphical applications on a remote system, by tunneling port 14500 via SSH.


#### Running GUI/X11 applications with Docker and local X11-Server

Running X11/GUI applications in a Docker container, using a local X11 server (outside of the container) as the display, is possible but non-trivial on any host OS. On a local system, it will perform better than using Xpra, but is also potentially less secure.

##### OS-X

Before starting the container, you will need to

* Install XQuartz (https://www.xquartz.org/)

* Start XQuartz, and enable ["Allow connections from network clients"](https://blogs.oracle.com/oraclewebcentersuite/running-gui-applications-on-native-docker-containers-for-mac) in the XQuartz preferences ("Security" tab).

* Quite and restart XQuartz to activate the new security settings

In a terminal (outside of the container), run

```shell
# allow X11 access from localhost:
xhost + 127.0.0.1
# allow indirect GLX, for OpenGL programs:
defaults write org.macosforge.xquartz.X11 enable_iglx -bool true

docker run -it --rm \
    -v "$HOME":"/home/user" \
    -v "$HOME/legend-base":"/root":delegated \
    -e DISPLAY=host.docker.internal:0 \
    legendexp/legend-base:latest
```

This will start a container with an interactive X11-enabled bash shell. You should now be able to run X11/GUI programs. See the Jupyter example above for the meaning of the `-it`, `--rm` and `-v` options.

**Note:** Using `xhost + 127.0.0.1` is less than optimal from a security point of view! It is only barely acceptable on a single user system, and *must not* be used on a system with multiple users. Is may be possible to bind the ".Xauthority" from the host into the container instead, but at least on OS-X that alone doesn't seem to be sufficient.
