# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.

DEFAULT_BUILD_OPTS="-Dbuiltin_davix=ON -Dbuiltin_lzma=ON -Dbuiltin_pcre=ON -Dbuiltin_unuran=ON -Dbuiltin_vc=ON -Dbuiltin_vdt=ON -Dbuiltin_veccore=ON -Dbuiltin_zlib=ON -Dbuiltin_zstd=OFF -Dfortran=ON -Dminuit2=ON -Dpythia8=OFF -Dshadowpw=ON -Dsoversion=ON -Dunuran=ON -Dvmc=ON"

pkg_install() {
    source disable-conda.sh
    
    DOWNLOAD_URL="https://root.cern/download/root_v${PACKAGE_VERSION}.source.tar.gz"
    echo "INFO: Download URL: \"${DOWNLOAD_URL}\"." >&2

    mkdir src build
    mkdir -p "${INSTALL_PREFIX}"
    download "${DOWNLOAD_URL}" | tar --strip-components 1 -C src --strip=1 -x -z
    cd build
    
    cmake \
	 -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
	 -DPython3_ROOT_DIR=${CONDA_PREFIX}/bin \
	 ${DEFAULT_BUILD_OPTS} \
	 ../src
    
    time make -j"$(nproc)" install
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH"
MANPATH="${INSTALL_PREFIX}/man:\$MANPATH"
PYTHONPATH="${INSTALL_PREFIX}/lib:\$PYTHONPATH"
CMAKE_PREFIX_PATH="${INSTALL_PREFIX};\$CMAKE_PREFIX_PATH"
JUPYTER_PATH="${INSTALL_PREFIX}/etc/notebook:\$JUPYTER_PATH"
ROOTSYS="${INSTALL_PREFIX}"
export PATH LD_LIBRARY_PATH MANPATH PYTHONPATH CMAKE_PREFIX_PATH JUPYTER_PATH ROOTSYS
EOF
}
