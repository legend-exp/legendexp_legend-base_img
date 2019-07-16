# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2017: Oliver Schulz.


DEFAULT_BUILD_OPTS=""


pkg_installed_check() {
    test -f "${INSTALL_PREFIX}/bin/dcraw"
}


pkg_install() {
    test "${PACKAGE_VERSION}" = "current"
    wget http://www.dechifro.org/dcraw/dcraw.c
    gcc -g -O2 dcraw.c -o dcraw -llcms2 -ljasper -ljpeg -lm

    mkdir -p "${INSTALL_PREFIX}/bin"
    cp -a dcraw "${INSTALL_PREFIX}/bin"
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
export PATH
EOF
}
