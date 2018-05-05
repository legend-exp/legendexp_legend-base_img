# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2018: Oliver Schulz.


pkg_installed_check() {
    export PATH="${INSTALL_PREFIX}/usr/bin:${INSTALL_PREFIX}/bin::$PATH"
    JULIA_PKGDIR=`julia -e 'println(dirname(last(LOAD_PATH)))'`
    ls "${JULIA_PKGDIR}/"*"/META_BRANCH" >/dev/null 2>/dev/null
    false
}


pkg_install() {
    export PATH="${INSTALL_PREFIX}/usr/bin:${INSTALL_PREFIX}/bin::$PATH"
    export JULIA_PKGDIR=`julia -e 'println(dirname(last(LOAD_PATH)))'`
    echo "INFO: JULIA_PKGDIR=\"${JULIA_PKGDIR}\"." >&2

    julia -e 'Pkg.init()'
    pkgdir=`julia -e 'println(Pkg.dir())'`
    # echo "pkgdir = $pkgdir"
    # meta_branch=`(cd "${pkgdir}/METADATA" && git rev-parse --abbrev-ref HEAD)`
    # echo "meta_branch = $meta_branch"
    (cd "${pkgdir}/METADATA" && git reset --hard "${PACKAGE_VERSION}")
    test -f "${pkgdir}/REQUIRE"

    #!cat "${SCRIPT_DIR}/data/julia/REQUIRE" >> "${pkgdir}/REQUIRE"
    cat "${SCRIPT_DIR}/data/julia/REQUIRE" > "${pkgdir}/REQUIRE" #!

    # Ensure IJulia Jupyer kernel is installed in site-wide directory
    export JUPYTER_DATA_DIR=`python -c 'import jupyter_core.paths; print(jupyter_core.paths.jupyter_path()[-3])'`
    echo "INFO: JUPYTER_DATA_DIR=\"${JUPYTER_DATA_DIR}\"." >&2

    # Use CPU backend for ArrayFire.jl during package installation and precompilation
    export JULIA_ARRAYFIRE_BACKEND=cpu

    # Install packages in REQUIRE
    julia -e 'Pkg.resolve()'

    # Precompile  packages in REQUIRE
    xvfb-run --server-args="-screen 0 1024x768x24" julia -e 'foreach(pkg -> eval(:(info("import " * $pkg); import $(Symbol(pkg)))), sort!(collect(keys(Pkg.Reqs.parse(Pkg.dir("REQUIRE"))))))'

    # Modify site-wide juliarc.jl
    juliarc=`julia -e 'println(joinpath(dirname(JULIA_HOME), "etc", "julia", "juliarc.jl"))'`
    echo "DEBUG: juliarc=\"${juliarc}\"." >&2

cat >> "${juliarc}" <<EOF

# Custom addition: If no user package directory exists, use site package
# directory for LOAD_CACHE_PATH
if !ispath(Pkg.dir()) && !ispath(Base.LOAD_CACHE_PATH[1])
    Base.LOAD_CACHE_PATH[1] = joinpath(dirname(last(LOAD_PATH)), "lib", basename(last(LOAD_PATH)))
end
EOF

    julia_bindir=`julia -e 'println(JULIA_HOME)'`
    echo "DEBUG: julia_bindir=\"${julia_bindir}\"." >&2
    cp -a "${SCRIPT_DIR}/data/julia/init-julia-user-pkgdir" "${julia_bindir}"

    rm -rf "${pkgdir}/.cache"
    rm -rf "$HOME/.jupyter"
}


pkg_env_vars() {
    export PATH="${INSTALL_PREFIX}/usr/bin:${INSTALL_PREFIX}/bin::$PATH"
    export JUPYTER_DATA_DIR=`julia -e 'println(joinpath(dirname(JULIA_HOME), "share", "jupyter"))'`

cat <<-EOF
JUPYTER_PATH="${JUPYTER_DATA_DIR}:\$JUPYTER_PATH"
EOF
}
