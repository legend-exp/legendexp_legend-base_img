# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_installed_check() {
    test -f "${INSTALL_PREFIX}/bin/julia"
}


pkg_install() {
    PACKAGE_VERSION_MAJOR=`echo "${PACKAGE_VERSION}" | cut -f 1,2 -d . | grep -o '[0-9.]*'`

    DOWNLOAD_URL="https://julialang-s3.julialang.org/bin/linux/x64/${PACKAGE_VERSION_MAJOR}/julia-${PACKAGE_VERSION}-linux-x86_64.tar.gz"
    echo "INFO: Download URL: \"${DOWNLOAD_URL}\"." >&2

    mkdir -p "${INSTALL_PREFIX}"
    download "${DOWNLOAD_URL}" \
        | tar --strip-components=1 -x -z -f - -C "${INSTALL_PREFIX}"

    # For rjulia and embedding Julia:
    (cd "${INSTALL_PREFIX}/lib" && ln -s "julia/libstdc++.so.6" .)
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
MANPATH="${INSTALL_PREFIX}/share/man:\$MANPATH"
export PATH LD_LIBRARY_PATH MANPATH JULIA_HOME
EOF
}
