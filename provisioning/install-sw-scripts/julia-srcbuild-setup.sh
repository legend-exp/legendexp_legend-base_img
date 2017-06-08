# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_installed_check() {
    test -f "${INSTALL_PREFIX}/bin/julia"
}


pkg_install() {
    GITHUB_USER=`echo "${PACKAGE_VERSION}" | cut -d '/' -f 1`
    GIT_BRANCH=`echo "${PACKAGE_VERSION}" | cut -d '/' -f 2`

    # Source build of Julia, don't build binary-dist to make Cxx.jl
    # installations leaner to support LLVM.jl:

    git clone "https://github.com/${GITHUB_USER}/julia"
    cd julia
    git checkout "${GIT_BRANCH}"
    time make -j"$(nproc)" all debug
    mkdir -p "${INSTALL_PREFIX}"
    symlinks -r -c .
    rsync -a "usr" "base" "test" "LICENSE.md" "${INSTALL_PREFIX}/"
    # For Julia v0.5:
    test -d "/usr/include/julia" || rsync -a "src" "${INSTALL_PREFIX}/"
    # For Cxx.jl:
    mkdir -p "${INSTALL_PREFIX}/deps" && rsync -a "deps/Versions.make" "${INSTALL_PREFIX}/deps/Versions.make"
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
