# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2017: Oliver Schulz.


pkg_install() {
    DOWNLOAD_URL="http://support.hdfgroup.org/ftp/HDF5/hdf-java/current/bin/HDFView-${PACKAGE_VERSION}-centos6-x64.tar.gz"
    echo "INFO: Download URL: \"${DOWNLOAD_URL}\"." >&2

    download "${DOWNLOAD_URL}" \
        | tar -x -z -f -

    sh "HDFView-${PACKAGE_VERSION}-Linux.sh" --skip-license

    mkdir -p "${INSTALL_PREFIX}"

    JAVA_BIN_DIR="$(dirname `which java`)"
    if [ -z "${JAVA_BIN_DIR}" ] ; then
        echo "ERROR: No \"java\" executable on \$PATH" >&2
        return 1
    fi

    HDFVIEW_SCRIPT="HDFView/${PACKAGE_VERSION}/hdfview.sh"
    sed "s|export JAVABIN=.*$|export JAVABIN=\"${JAVA_BIN_DIR}\"|" -i "${HDFVIEW_SCRIPT}"
    sed "s|export INSTALLDIR=.*$|export INSTALLDIR=\"${INSTALL_PREFIX}\"|" -i "${HDFVIEW_SCRIPT}"
    mkdir -p "${INSTALL_PREFIX}/bin"
    mv "${HDFVIEW_SCRIPT}" "${INSTALL_PREFIX}/bin/hdfview"

    mv "HDFView/${PACKAGE_VERSION}/lib" "${INSTALL_PREFIX}/"
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
export PATH
EOF
}
