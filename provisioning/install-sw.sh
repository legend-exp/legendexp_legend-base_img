#!/bin/bash -e

# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


# ===========================================================================

# Installer scripts must define function "pkg_install"

# ===========================================================================


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

get_linux_dist_info() {
    LINUX_DIST="unknown"
    LINUX_DIST_NAME="unknown"
    LINUX_DIST_VERSION="unknown"
    LINUX_DIST_FAMILY="unknown"
    LINUX_DIST_BINCOMPAT="unknown"

    if [ -f /etc/debian_version ] ; then
        LINUX_DIST_FAMILY="debian"
        local VER_STRING=`cat /etc/issue.net | head -n1`
        if (echo "${VER_STRING}" | grep -q '^Debian GNU/Linux \([0-9]\).*$') ; then
            LINUX_DIST_NAME="debian"
            LINUX_DIST_VERSION=`echo "${VER_STRING}" | sed 's@^Debian GNU/Linux \([0-9]\).*$@\1@'`
        elif (echo "${VER_STRING}" | grep -q '^Ubuntu \([0-9][0-9][.][0-9][0-9]\).*$') ; then
            LINUX_DIST_NAME="ubuntu"
            LINUX_DIST_VERSION=`echo "${VER_STRING}" | sed 's@^Ubuntu \([0-9][0-9][.][0-9][0-9]\).*$@\1@'`
        else
            LINUX_DIST_VERSION="unknown"
        fi
        LINUX_DIST_BINCOMPAT="${LINUX_DIST_NAME}-${LINUX_DIST_VERSION}"
    elif [ -f /etc/redhat-release ] ; then
        LINUX_DIST_FAMILY="rhel"
        local VER_STRING=`cat /etc/redhat-release | head -n1`
        local VER_INFO=`echo "${VER_STRING}" | sed 's@^\(.*\) release \([0-9]\).*$@\1:\2@; s@ Linux\| CERN\| SLC@@g; s@\s@@g' | tr '[:upper:]' '[:lower:]'`
        LINUX_DIST_NAME=`echo "${VER_INFO}" | cut -d ':' -f 1`
        LINUX_DIST_VERSION=`echo "${VER_INFO}" | cut -d ':' -f 2`
        LINUX_DIST_BINCOMPAT="${LINUX_DIST_FAMILY}-${LINUX_DIST_VERSION}"
    fi
    LINUX_DIST="${LINUX_DIST_NAME}-${LINUX_DIST_VERSION}"

    echo "Linux distribution: ${LINUX_DIST} (${LINUX_DIST_FAMILY} family, bin-compat to ${LINUX_DIST_BINCOMPAT})"
}


download() {
    if (hash curl 2>/dev/null) ; then
        curl -L "$1"
    elif (hash wget 2>/dev/null) ; then
        wget -O- "$1"
    else
        echo "Error: Neither curl nor wget available." >&2
        exit 1
    fi
}


in_buildarea() {
    BUILDAREA=`mktemp -d -t "build-${PACKAGE_NAME}-XXXXXX"`
    echo "Build area: \"${BUILDAREA}\""
    cd "${BUILDAREA}"
    "$@"
    rm -rf "${BUILDAREA}"
}


pkg_installed_check() {
    test -f "${INSTALL_PREFIX}/bin/${PACKAGE_NAME}-config"
}


pkg_env_vars() {
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib:\$LD_LIBRARY_PATH"
MANPATH="${INSTALL_PREFIX}/share/man:\$MANPATH"
export PATH LD_LIBRARY_PATH MANPATH
EOF
}


PACKAGE_NAME="$1"
PACKAGE_VERSION="$2"
INSTALL_PREFIX="$3"

if [ -z "${PACKAGE_NAME}" -o -z "${PACKAGE_VERSION}" -o -z "${INSTALL_PREFIX}" ] ; then
    echo "ERROR: Syntax: ${0} PACKAGE_NAME PACKAGE_VERSION INSTALL_PREFIX [...]" >&2
    exit 1
fi

shift 3


get_linux_dist_info

. "${SCRIPT_DIR}/install-sw-scripts/${PACKAGE_NAME}-setup.sh"

test -n "${PACKAGE_VERSION}"

if pkg_installed_check; then
    echo "INFO: ${PACKAGE_NAME}-${PACKAGE_VERSION} already installed." >&2
else
    echo "INFO: Installing ${PACKAGE_NAME}-${PACKAGE_VERSION} to ${INSTALL_PREFIX}" >&2
    echo "Number of threads available: $(nproc)"
    in_buildarea pkg_install "$@"
    echo "INFO: Successfully installed ${PACKAGE_NAME}-${PACKAGE_VERSION} to ${INSTALL_PREFIX}" >&2
fi

echo >&2
echo "INFO: Environment variables for ${PACKAGE_NAME}-${PACKAGE_VERSION}:" >&2
pkg_env_vars
echo >&2
