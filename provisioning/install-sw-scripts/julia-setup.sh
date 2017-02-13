# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_installed_check() {
    test -f "${INSTALL_PREFIX}/bin/julia"
}


pkg_install() {
    DOWNLOAD_URL="https://julialang.s3.amazonaws.com/bin/linux/x64/0.5/julia-${PACKAGE_VERSION}-linux-x86_64.tar.gz"
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
LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH"
MANPATH="${INSTALL_PREFIX}/share/man:\$MANPATH"
JULIA_HOME="${INSTALL_PREFIX}/bin"
export PATH LD_LIBRARY_PATH MANPATH JULIA_HOME
EOF
}
