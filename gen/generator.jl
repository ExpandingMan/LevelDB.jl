# see https://juliainterop.github.io/Clang.jl/stable/generator/
using Clang
using Clang.Generators
using LevelDB_jll

cd(@__DIR__)

include_dir = joinpath(LevelDB_jll.artifact_dir,"include")

opts = load_options(joinpath(@__DIR__,"generator.toml"))

args = get_default_args()
push!(args, "-I$include_dir")

ctx = create_context([joinpath(include_dir,"leveldb","c.h")], args, opts)

build!(ctx)
