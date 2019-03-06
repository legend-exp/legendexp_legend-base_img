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
    git clone "https://github.com/${GITHUB_USER}/incubator-mxnet" mxnet
    (
        cd mxnet
        git fetch
        git checkout "${GIT_BRANCH}"
        git submodule update --init --recursive --no-recommend-shallow
    )

    cd mxnet

    (
        mkdir build && cd build
        cmake \
            -DUSE_BLAS=openblas \
            -DUSE_CUDA=1 \
            -DUSE_CUDA_PATH="/usr/local/cuda" \
            -DUSE_CUDNN=1 \
            -DUSE_CPP_PACKAGE=1 \
            -GNinja ..
        ninja-build -v
    )

    mkdir -p "${INSTALL_PREFIX}"
    cp -a include "${INSTALL_PREFIX}/"
    mkdir "${INSTALL_PREFIX}/lib/"
    cp -a lib/*.so* "${INSTALL_PREFIX}/lib/"

    (cd python && pip install -e .)
    cp -a julia "${INSTALL_PREFIX}/"
}


pkg_env_vars() {
cat <<-EOF
LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH"
MXNET_HOME="${INSTALL_PREFIX}"
export LD_LIBRARY_PATH MXNET_HOME
EOF
}
