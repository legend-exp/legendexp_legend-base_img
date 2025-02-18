# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_installed_check() {
    test -f "${INSTALL_PREFIX}/bin/conda"
}


pkg_install() {
    DOWNLOAD_URL="https://repo.continuum.io/archive/Anaconda2-${PACKAGE_VERSION}-Linux-x86_64.sh"
    echo "INFO: Download URL: \"${DOWNLOAD_URL}\"." >&2

    download "${DOWNLOAD_URL}" > anaconda-installer.sh
    bash ./anaconda-installer.sh -b -p "${INSTALL_PREFIX}"
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
MANPATH="${INSTALL_PREFIX}/share/man:\$MANPATH"
EOF
}
