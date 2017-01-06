# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_installed_check() {
    export JULIA_PKGDIR="${INSTALL_PREFIX}"
    CXX_PKG_DIR=`julia -e 'println(Pkg.dir("Cxx"))'`

    test -f "${CXX_PKG_DIR}"
}


pkg_install() {
    export JULIA_PKGDIR="${INSTALL_PREFIX}"
    CXX_PKG_DIR=`julia -e 'println(Pkg.dir("Cxx"))'`

    julia -e 'isdir(joinpath(Pkg.dir(), "METADATA")) || Pkg.init()'

    GITHUB_USER=`echo "${PACKAGE_VERSION}" | cut -d '/' -f 1`
    GIT_BRANCH=`echo "${PACKAGE_VERSION}" | cut -d '/' -f 2`
    echo julia -e 'Pkg.clone("https://github.com/'"${GITHUB_USER}"'/Cxx.jl.git"); Pkg.checkout("Cxx", "'"${GIT_BRANCH}"'"); Pkg.build("Cxx")'
    julia -e 'Pkg.clone("https://github.com/'"${GITHUB_USER}"'/Cxx.jl.git"); Pkg.checkout("Cxx", "'"${GIT_BRANCH}"'"); Pkg.build("Cxx")'

    test -d "${CXX_PKG_DIR}"
    (cd "${CXX_PKG_DIR}/deps" && mkdir tmp && mv build src tmp)
    (
        cd "${CXX_PKG_DIR}/deps/tmp" \
        && tar -c -f - */*/include */*/*/*/*/include build/clang_constants.jl
    ) | (
        cd "${CXX_PKG_DIR}/deps" \
        && tar -x -f - 
    )
    rm -rf "${CXX_PKG_DIR}/deps/tmp"

    julia -e 'Pkg.test("Cxx")'
}


pkg_env_vars() {
    true
}
