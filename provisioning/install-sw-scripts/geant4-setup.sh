# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2016: Oliver Schulz.


BASIC_BUILD_OPTS="\
--fail-on-missing \
--enable-shared \
--enable-soversion \
"

ADDITIONAL_BUILD_OPTS="\
-DGEANT4_USE_GDML=ON \
-DGEANT4_USE_OPENGL_X11=ON \
-DGEANT4_USE_RAYTRACER_X11=ON \
-DGEANT4_INSTALL_DATA=ON \
-DGEANT4_INSTALL_EXAMPLES=ON \
"

CLHEP_PREFIX=`(clhep-config --prefix | sed 's/\"//g') 2> /dev/null`
if [ -n "${CLHEP_PREFIX}" ] ; then
    echo "INFO: `clhep-config --version` available, will use it for Geant4 installation."

    BASIC_BUILD_OPTS="${BASIC_BUILD_OPTS} -DGEANT4_USE_SYSTEM_CLHEP=ON -DCLHEP_ROOT_DIR=${CLHEP_PREFIX}"
else
    BASIC_BUILD_OPTS="${BASIC_BUILD_OPTS} -DGEANT4_USE_SYSTEM_CLHEP=OFF"
fi

DEFAULT_BUILD_OPTS=`echo ${BASIC_BUILD_OPTS} ${ADDITIONAL_BUILD_OPTS}`


download_url() {
    # Note: Currently using plain HTTP, as the SSL cert of geant4.cern.ch is expired.
    local PKG_VERSION="${1}" \
    && local PKG_VERSION_MAJOR=$(echo "${PKG_VERSION}" | cut -d '.' -f 1) \
    && local PKG_VERSION_MINOR=$(echo "${PKG_VERSION}" | cut -d '.' -f 2) \
    && local PKG_VERSION_MINOR=$(test "${PKG_VERSION_MAJOR}" -ge 10 && seq -f "%02g" "${PKG_VERSION_MINOR}" "${PKG_VERSION_MINOR}" || echo "${PKG_VERSION_MINOR}") \
    && local PKG_VERSION_PATCH=$(echo "${PKG_VERSION}" | cut -d '.' -f 3) \
    && local PKG_VERSION_PATCH=$(seq -f "%02g" "${PKG_VERSION_PATCH}" "${PKG_VERSION_PATCH}") \
    && local PKG_VERSION_DNL="${PKG_VERSION_MAJOR}.${PKG_VERSION_MINOR}" \
    && local PKG_VERSION_DNL=$(test "${PKG_VERSION_PATCH}" -ne 0 && echo "${PKG_VERSION_DNL}.p${PKG_VERSION_PATCH}" || echo "${PKG_VERSION_DNL}") \
    && echo "http://geant4.cern.ch/support/source/geant4.${PKG_VERSION_DNL}.tar.gz"
}


pkg_install() {
    DOWNLOAD_URL=`download_url "${PACKAGE_VERSION}"`
    echo "INFO: Download URL: \"${DOWNLOAD_URL}\"." >&2

    mkdir src build
    curl -L "${DOWNLOAD_URL}" | tar --strip-components 1 -C src --strip=1 -x -z
    cd build

    cmake \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        ${DEFAULT_BUILD_OPTS} \
        ../src

    time make "-j${NTHREADS}" install
}


pkg_env_vars() {
export LD_LIBRARY_PATH=""
. "${INSTALL_PREFIX}/bin/geant4.sh"
cat <<-EOF
PATH="${INSTALL_PREFIX}/bin:\$PATH"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:\$LD_LIBRARY_PATH"
EOF
G4_DATA_VARS="$(echo `env|grep -o '^G4.*DATA='|sed 's/=//' | sort`)"
env|grep '^G4.*DATA='|sort
cat <<-EOF
export PATH LD_LIBRARY_PATH ${G4_DATA_VARS}
EOF
}
