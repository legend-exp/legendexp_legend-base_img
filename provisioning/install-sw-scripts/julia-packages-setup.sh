# This software is licensed under the MIT "Expat" License.
#
# Copyright (c) 2018: Oliver Schulz.


pkg_installed_check() {
    export PATH="${INSTALL_PREFIX}/usr/bin:${INSTALL_PREFIX}/bin::$PATH"
    JULIA_PKGDIR=`julia -e 'println(joinpath(dirname(JULIA_HOME), "share", "julia", "packages"))'`
    ls "${JULIA_PKGDIR}/"*"/META_BRANCH" >/dev/null 2>/dev/null
    false
}


pkg_install() {
    export PATH="${INSTALL_PREFIX}/usr/bin:${INSTALL_PREFIX}/bin::$PATH"
    export JULIA_PKGDIR=`julia -e 'println(joinpath(dirname(JULIA_HOME), "share", "julia", "packages"))'`
    echo "INFO: JULIA_PKGDIR=\"${JULIA_PKGDIR}\"." >&2

    julia -e 'Pkg.init()'
    pkgdir=`julia -e 'println(Pkg.dir())'`
    # echo "pkgdir = $pkgdir"
    # meta_branch=`(cd "${pkgdir}/METADATA" && git rev-parse --abbrev-ref HEAD)`
    # echo "meta_branch = $meta_branch"
    (cd "${pkgdir}/METADATA" && git reset --hard "${PACKAGE_VERSION}")
    test -f "${pkgdir}/REQUIRE"

    # Installed patched Cxx.jl with support for env variable JULIA_CXX_CPU:
    julia -e 'Pkg.clone("https://github.com/oschulz/Cxx.jl.git"); Pkg.checkout("Cxx", "julia_cxx_cpu"); Pkg.build("Cxx")'

    #!cat "${SCRIPT_DIR}/data/julia/REQUIRE" >> "${pkgdir}/REQUIRE"
    cat "${SCRIPT_DIR}/data/julia/REQUIRE" > "${pkgdir}/REQUIRE" #!

    # Ensure IJulia Jupyer kernel is installed in site-wide directory
    export JUPYTER_DATA_DIR=`python -c 'import jupyter_core.paths; print(jupyter_core.paths.jupyter_path()[-3])'`
    echo "INFO: JUPYTER_DATA_DIR=\"${JUPYTER_DATA_DIR}\"." >&2

    # Use CPU backend for ArrayFire.jl during package installation and precompilation
    export JULIA_ARRAYFIRE_BACKEND=cpu

    # Install packages in REQUIRE
    julia -e 'Pkg.resolve()'

    JULIA_PRECOMP_DIR=`julia -e 'println(joinpath(dirname(Pkg.dir()), "lib", basename(Pkg.dir())))'`

    # Precompile  packages in REQUIRE
    julia -e 'isdir(Pkg.dir("IntervalArithmetic")) && import IntervalArithmetic'
    xvfb-run --server-args="-screen 0 1024x768x24" julia -e 'foreach(pkg -> eval(:(info("import " * $pkg); import $(Symbol(pkg)))), sort!(collect(keys(Pkg.Reqs.parse(Pkg.dir("REQUIRE"))))))'
    chmod -R g+rX,o+rX "${JULIA_PRECOMP_DIR}/"

    # Modify site-wide juliarc.jl
    juliarc=`julia -e 'println(joinpath(dirname(JULIA_HOME), "etc", "julia", "juliarc.jl"))'`
    echo "DEBUG: juliarc=\"${juliarc}\"." >&2

cat >> "${juliarc}" <<"EOF"

# Custom addition: If no user package directory exists, use preinstalled
# packages and precompilation cache.
if !ispath(Pkg.dir())
    if parse(Int, get(ENV, "JULIA_FORCE_ORIG_PKGDIR", "1")) <= 0
        let
            old_cachedir = joinpath(dirname(Pkg.dir()), "lib", basename(Pkg.dir()))
            ENV["JULIA_PKGDIR"] = joinpath(dirname(JULIA_HOME), "share", "julia", "packages")
            new_cachedir = joinpath(dirname(Pkg.dir()), "lib", basename(Pkg.dir()))
            for i in eachindex(Base.LOAD_CACHE_PATH)
                if Base.LOAD_CACHE_PATH[i] == old_cachedir
                    Base.LOAD_CACHE_PATH[i] = new_cachedir
                end
            end
            nothing
        end
    end
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
