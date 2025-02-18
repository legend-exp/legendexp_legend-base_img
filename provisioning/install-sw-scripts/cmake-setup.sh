# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_installed_check() {
    test -f "${INSTALL_PREFIX}/bin/cmake"
}


pkg_install() {
    PACKAGE_VERSION_SHORT=`echo "${PACKAGE_VERSION}" | cut -d '.' -f 1,2`
    DOWNLOAD_URL="https://cmake.org/files/v${PACKAGE_VERSION_SHORT}/cmake-${PACKAGE_VERSION}-Linux-x86_64.tar.gz"
    echo "INFO: Download URL: \"${DOWNLOAD_URL}\"." >&2

    mkdir -p "${INSTALL_PREFIX}"
    download "${DOWNLOAD_URL}" \
        | tar --strip-components=1 -x -z -f - -C "${INSTALL_PREFIX}"
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
MANPATH="${INSTALL_PREFIX}/share/man:\$MANPATH"
export PATH MANPATH
EOF
}
