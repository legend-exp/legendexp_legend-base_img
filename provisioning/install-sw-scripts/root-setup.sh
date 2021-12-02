# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_install() {
    DOWNLOAD_URL=""
    if [ "${LINUX_DIST_BINCOMPAT}" = "ubuntu-20.04" ] ; then
        DOWNLOAD_URL="https://root.cern.ch/download/root_v${PACKAGE_VERSION}.Linux-ubuntu20-x86_64-gcc9.3.tar.gz"
    elif [ "${LINUX_DIST_BINCOMPAT}" = "rhel-7" ] ; then
        DOWNLOAD_URL="https://root.cern.ch/download/root_v${PACKAGE_VERSION}.Linux-centos7-x86_64-gcc4.8.tar.gz"
    else
        echo "ERROR: Unsupported Linux distribution (binary compatible) \"${LINUX_DIST_BINCOMPAT}\"".
        exit 1
    fi
    echo "INFO: Download URL: \"${DOWNLOAD_URL}\"." >&2

    mkdir -p "${INSTALL_PREFIX}"
    download "${DOWNLOAD_URL}" \
        | tar --strip-components=1 -x -z -f - -C "${INSTALL_PREFIX}"
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH"
MANPATH="${INSTALL_PREFIX}/man:\$MANPATH"
PYTHONPATH="${INSTALL_PREFIX}/lib:\$PYTHONPATH"
CMAKE_PREFIX_PATH="${INSTALL_PREFIX};\$CMAKE_PREFIX_PATH"
JUPYTER_PATH="${INSTALL_PREFIX}/etc/notebook:\$JUPYTER_PATH"
ROOTSYS="${INSTALL_PREFIX}"
export PATH LD_LIBRARY_PATH MANPATH PYTHONPATH CMAKE_PREFIX_PATH JUPYTER_PATH ROOTSYS
EOF
}
