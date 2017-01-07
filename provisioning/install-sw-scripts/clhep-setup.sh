# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


DEFAULT_BUILD_OPTS=""


pkg_install() {
    DOWNLOAD_URL="https://proj-clhep.web.cern.ch/proj-clhep/DISTRIBUTION/tarFiles/clhep-${PACKAGE_VERSION}.tgz"
    echo "INFO: Download URL: \"${DOWNLOAD_URL}\"." >&2

    mkdir src build
    download "${DOWNLOAD_URL}" | tar --strip-components 1 -C src --strip=1 -x -z
    cd build

    cmake \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        ${DEFAULT_BUILD_OPTS} \
        ../src/CLHEP

    time make "-j${NTHREADS}" install
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH"
export PATH LD_LIBRARY_PATH
EOF
}
