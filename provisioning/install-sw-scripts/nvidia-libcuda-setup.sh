# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


pkg_install() {
    DOWNLOAD_URL="http://download.nvidia.com/XFree86/Linux-x86_64/${PACKAGE_VERSION}/NVIDIA-Linux-x86_64-${PACKAGE_VERSION}.run"
    echo "INFO: Download URL: \"${DOWNLOAD_URL}\"." >&2

    download "${DOWNLOAD_URL}" > "NVIDIA-Linux-x86_64-${PACKAGE_VERSION}.run"
    bash "NVIDIA-Linux-x86_64-${PACKAGE_VERSION}.run" --extract-only
    CURRDIR=`pwd`
    mkdir -p "${INSTALL_PREFIX}"
    cd "NVIDIA-Linux-x86_64-${PACKAGE_VERSION}"
    cp -a "libcuda.so.${PACKAGE_VERSION}" "libnvidia-fatbinaryloader.so.${PACKAGE_VERSION}" "${INSTALL_PREFIX}/"
    (cd "${INSTALL_PREFIX}" && ln -s "libcuda.so.${PACKAGE_VERSION}" "libcuda.so.1")
}


pkg_env_vars() {
	true
}
