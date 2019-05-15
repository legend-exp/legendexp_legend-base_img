# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2018: Oliver Schulz.


pkg_installed_check() {
    test -d "${INSTALL_PREFIX}/packages"
}


pkg_install() {
    export JULIA_DEPOT_PATH="${INSTALL_PREFIX}"
    wget https://raw.githubusercontent.com/legend-exp/legend-julia-tutorial/master/install_julia_packages.jl
    julia install_julia_packages.jl
    julia -e 'using Pkg; pkg"precompile"'
}


pkg_env_vars() {
    true
}
