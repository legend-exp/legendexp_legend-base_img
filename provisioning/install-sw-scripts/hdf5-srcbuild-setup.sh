# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_installed_check() {
    test -f "${INSTALL_PREFIX}/bin/h5ls"
}

pkg_install() {
    PACKAGE_VERSION_MAJOR=`echo "${PACKAGE_VERSION}" | cut -f 1,2 -d .`
    VERSION_WITH_UNDERSCORES=`echo $PACKAGE_VERSION | sed 's/\./_/g'`
    DOWNLOAD_URL="https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF5/HDF5_${VERSION_WITH_UNDERSCORES}/src/hdf5-${PACKAGE_VERSION}.tar.bz2"

    mkdir hdf5
    download "${DOWNLOAD_URL}" \
        | tar --strip-components=2 -x -j -f - -C hdf5

    cd hdf5

    ./configure --prefix="${INSTALL_PREFIX}" \
        --enable-build-mode=production \
        --enable-threadsafe --enable-unsupported \
        --enable-cxx \
        --enable-java

    make -j"$(nproc)" install
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH"
export PATH LD_LIBRARY_PATH
EOF
}
