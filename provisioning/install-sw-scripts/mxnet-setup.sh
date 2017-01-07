# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2017: Oliver Schulz.


DEFAULT_BUILD_OPTS=""


pkg_installed_check() {
    test -f "${INSTALL_PREFIX}/lib/libmxnet.so"
}


pkg_install() {
    GITHUB_USER=`echo "${PACKAGE_VERSION}" | cut -d '/' -f 1`
    GIT_BRANCH=`echo "${PACKAGE_VERSION}" | cut -d '/' -f 2`
    git clone --recursive "https://github.com/${GITHUB_USER}/mxnet" --branch "${GIT_BRANCH}"

    cd mxnet

    cp make/config.mk config.mk
    sed -i 's/USE_BLAS = atlas/USE_BLAS = openblas/g' config.mk
    sed -i 's/USE_CUDA = 0/USE_CUDA = 1/g' config.mk
    sed -i 's/USE_CUDA_PATH = NONE/USE_CUDA_PATH = \/usr\/local\/cuda/g' config.mk
    sed -i 's/USE_CUDNN = 0/USE_CUDNN = 1/g' config.mk

    CPATH=/usr/include/openblas make -j"$(nproc)"

    mkdir -p "${INSTALL_PREFIX}"
    cp -a include "${INSTALL_PREFIX}/"
    mkdir "${INSTALL_PREFIX}/lib/"
    cp -a lib/*.so* "${INSTALL_PREFIX}/lib/"
}


pkg_env_vars() {
cat <<-EOF
LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH"
MXNET_HOME="${INSTALL_PREFIX}"
export LD_LIBRARY_PATH MXNET_HOME
EOF
}
