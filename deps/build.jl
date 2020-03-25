using Libdl

using BinaryProvider

# Dependencies that must be installed before this package can be built
dependencies = [
  # This has to be in sync with the corresponding commit in the source build below (for flint, arb, antic)
  "https://github.com/JuliaPackaging/Yggdrasil/releases/download/GMP-v6.1.2-1/build_GMP.v6.1.2.jl",
  "https://github.com/JuliaPackaging/Yggdrasil/releases/download/MPFR-v4.0.2-1/build_MPFR.v4.0.2.jl",
  "https://github.com/thofma/Flint2Builder/releases/download/dd1021/build_libflint.v0.0.0-dd1021a6cbaca75d94e6e066c26a3a5622884a7c.jl"
 ]

products = []

for url in dependencies
    build_file = joinpath(@__DIR__, basename(url))
    if !isfile(build_file)
        download(url, build_file)
    end
end

# Execute the build scripts for the dependencies in an isolated module to avoid overwriting
# any variables/constants here
for url in dependencies
    build_file = joinpath(@__DIR__, basename(url))
    m = @eval module $(gensym()); include($build_file); end
    append!(products, m.products)
end

const prefixpath = joinpath(@__DIR__, "usr")
filenames = ["libgmp.la", "libgmpxx.la", "libmpfr.la"]
for filename in filenames
  fpath = joinpath(prefixpath, "lib", filename)
  txt = read(fpath, String)
  open(fpath, "w") do f
    write(f, replace(txt, "/workspace/destdir" => prefixpath))
  end
end

push!(Libdl.DL_LOAD_PATH, joinpath(prefixpath, "lib"), joinpath(prefixpath, "bin"))
