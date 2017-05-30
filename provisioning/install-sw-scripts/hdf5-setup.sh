# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_installed_check() {
    test -f "${INSTALL_PREFIX}/bin/h5ls"
}


pkg_install() {
    PACKAGE_VERSION_MAJOR=`echo "${PACKAGE_VERSION}" | cut -f 1,2 -d .`

    DOWNLOAD_URL=""
    if [ "${LINUX_DIST_BINCOMPAT}" = "rhel-7" ] ; then
        DOWNLOAD_URL="https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-${PACKAGE_VERSION_MAJOR}/hdf5-${PACKAGE_VERSION}/bin/linux-centos7-x86_64-gcc485/hdf5-${PACKAGE_VERSION}-linux-centos7-x86_64-gcc485-shared.tar.gz"
    else
        echo "ERROR: Unsupported Linux distribution (binary compatible) \"${LINUX_DIST_BINCOMPAT}\"".
        exit 1
    fi
    echo "INFO: Download URL: \"${DOWNLOAD_URL}\"." >&2

    mkdir -p "${INSTALL_PREFIX}"
    download "${DOWNLOAD_URL}" \
        | tar --strip-components=1 -x -z -f - -C "${INSTALL_PREFIX}"

    find "${INSTALL_PREFIX}/lib" -name "libsz*" -type l -exec rm "{}" \;
    find "${INSTALL_PREFIX}/lib" -name "libz*" -type l -exec rm "{}" \;
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH"
export PATH LD_LIBRARY_PATH
EOF
}
