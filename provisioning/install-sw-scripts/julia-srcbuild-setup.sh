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


    # Checkout:
    git checkout "${GIT_BRANCH}"

    # For Cxx.jl:
    echo "BUILD_LLVM_CLANG=1" >> Make.user

    # Build:
    time make -j"$(nproc)" all debug
    symlinks -r -c .

    # Install:
    mkdir -p "${INSTALL_PREFIX}"
    rsync -a "usr" "base" "test" "LICENSE.md" "${INSTALL_PREFIX}/"
    rm -f "${INSTALL_PREFIX}/usr/bin"/*clang* "${INSTALL_PREFIX}/usr/bin"/scan-*

    # For Julia v0.7
    test -d "stdlib" && rsync -a "stdlib" "${INSTALL_PREFIX}/"

    # For Julia v0.5:
    test -d "/usr/include/julia" || rsync -a "src" "${INSTALL_PREFIX}/"

    # For Cxx.jl:
    rsync -a "Make.user" "${INSTALL_PREFIX}/"
    mkdir -p "${INSTALL_PREFIX}/deps" && rsync -a "deps/Versions.make" "${INSTALL_PREFIX}/deps/Versions.make"
    SRCCACHE_LLVM_PATH=`find deps/srccache -maxdepth 1 -type d -name "llvm-*" | head -n1`
    mkdir -p "${INSTALL_PREFIX}/${SRCCACHE_LLVM_PATH}/tools/clang"
    rsync -a "${SRCCACHE_LLVM_PATH}/tools/clang/"lib "${INSTALL_PREFIX}/${SRCCACHE_LLVM_PATH}/tools/clang/"
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
