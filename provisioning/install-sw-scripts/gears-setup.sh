# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2017: Oliver Schulz.


DEFAULT_BUILD_OPTS=""


pkg_installed_check() {
    test -f "${INSTALL_PREFIX}/bin/gears"
}


pkg_install() {
    GITHUB_USER=`echo "${PACKAGE_VERSION}" | cut -d '/' -f 1`
    GIT_BRANCH=`echo "${PACKAGE_VERSION}" | cut -d '/' -f 2`
    git clone "https://github.com/${GITHUB_USER}/gears" gears

    cd gears
    git checkout "${GIT_BRANCH}"

    hdf5_include_dir="$(dirname $(dirname $(command -v h5cc)))/include"

    export LD_LIBRARY_PATH=`echo $LD_LIBRARY_PATH | sed 's/:$//'`

    CPLUS_INCLUDE_PATH="${hdf5_include_dir}" make csv hdf5 xml

    mkdir -p "${INSTALL_PREFIX}/bin"
    cp -a gears.exe "${INSTALL_PREFIX}/bin/gears-root"
    cp -a gcsv.exe "${INSTALL_PREFIX}/bin/gears-csv"
    cp -a ghdf5.exe "${INSTALL_PREFIX}/bin/gears-hdf5"
    cp -a gxml.exe "${INSTALL_PREFIX}/bin/gears-xml"
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
export PATH
EOF
}
