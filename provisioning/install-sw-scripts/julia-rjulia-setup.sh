# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_installed_check() {
    test -f "${INSTALL_PREFIX}/bin/rjulia"
}


pkg_install() {
    GITHUB_USER=`echo "${PACKAGE_VERSION}" | cut -d '/' -f 1`
    GIT_BRANCH=`echo "${PACKAGE_VERSION}" | cut -d '/' -f 2`
    git clone "https://github.com/${GITHUB_USER}/ROOT.jl.git"
    (cd "ROOT.jl" && git checkout "${GIT_BRANCH}")

    cd "ROOT.jl/deps"
    julia build.jl
    mkdir -p "${INSTALL_PREFIX}/bin/"
    cp -a "usr/bin/julia" "${INSTALL_PREFIX}/bin/rjulia"
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
EOF
}
