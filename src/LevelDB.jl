module LevelDB

include("Lib.jl")
using .Lib
using .Lib: ldbcall


const AbstractVecOrString = Union{AbstractVector{UInt8},AbstractString}
const VecOrString = Union{Vector{UInt8},String}
const IteratorTypes = Union{typeof(keys),typeof(values),typeof(pairs)}


version() = VersionNumber(leveldb_major_version(), leveldb_minor_version(), 0)


mutable struct DBOptions
    handle::Ptr{leveldb_options_t}

    DBOptions(h::Ptr) = finalizer(x -> leveldb_options_destroy(x.handle), new(h))
end

function DBOptions(;kw...)
    h = leveldb_options_create()  # doesn't support error
    for (k, v) ∈ pairs(kw)
        #TODO: more
        if k == :error_if_exists
            leveldb_options_set_error_if_exists(h, Bool(v))
        elseif k == :create_if_missing
            leveldb_options_set_create_if_missing(h, Bool(v))
        else
            throw(ArgumentError("LevelDB options got unsupported keyword $k"))
        end
    end
    DBOptions(h)
end


mutable struct WriteOptions
    handle::Ptr{leveldb_writeoptions_t}

    WriteOptions(h::Ptr) = finalizer(x -> leveldb_writeoptions_destroy(x.handle), new(h))
end

function WriteOptions(;kw...)
    h = leveldb_writeoptions_create()
    for (k, v) ∈ pairs(kw)
        if false
            #TODO: more!
        else
            throw(ArgumentError("LevelDB write options got unsupported keyword $k"))
        end
    end
    WriteOptions(h)
end


mutable struct ReadOptions
    handle::Ptr{leveldb_readoptions_t}

    ReadOptions(h::Ptr) = finalizer(x -> leveldb_readoptions_destroy(x.handle), new(h))
end

function ReadOptions(;kw...)
    h = leveldb_readoptions_create()
    for (k, v) ∈ pairs(kw)
        if false
            #TODO: more!
        else
            throw(ArgumentError("LevelDB write options got unsupported keyword $k"))
        end
    end
    ReadOptions(h)
end


mutable struct DB{K<:VecOrString,V<:VecOrString}
    path::String
    handle::Ptr{leveldb_t}

    DB{K,V}(path::AbstractString, h::Ptr) where {K,V} = finalizer(close, new{K,V}(path, h))
end

function DB{K,V}(path::AbstractString, opts::DBOptions) where {K,V}
    h = ldbcall(leveldb_open, opts.handle, path)
    DB{K,V}(path, h)
end

DB{K,V}(path::AbstractString; kw...) where {K,V} = DB{K,V}(path, DBOptions(;kw...))

DB(path::AbstractString; kw...) = DB{String,Vector{UInt8}}(path; kw...)

function Base.show(io::IO, db::DB)
    show(io, typeof(db))
    print(io, "(")
    show(io, db.path)
    print(io, ")")
end

function Base.close(db::DB)
    leveldb_close(db.handle)
    db.handle == C_NULL
    nothing
end

Base.isopen(db::DB) = (db.handle ≠ C_NULL)

_checkopen(db::DB) = isopen(db) || error("operations on closed LevelDB database are forbidden")

_normalizekeyval(v::AbstractVector) = convert(Vector{UInt8}, v) 
_normalizekeyval(v::AbstractString) = _normalizekeyval(codeunits(v))

function Base.setindex!(db::DB, v::AbstractVecOrString, k::AbstractVecOrString, opts::WriteOptions)
    _checkopen(db)
    k = _normalizekeyval(k)
    v = _normalizekeyval(v)
    ldbcall(leveldb_put, db.handle, opts.handle, k, length(k), v, length(v)) 
end
Base.setindex!(db::DB, v::AbstractVecOrString, k::AbstractVecOrString; kw...) = setindex!(db, v, k, WriteOptions(;kw...))

function Base.getindex(db::DB, k::AbstractVecOrString, ::Type{Vector{UInt8}}, opts::ReadOptions)::Vector{UInt8}
    _checkopen(db)
    k = _normalizekeyval(k)
    olen = Ref{Csize_t}()
    o = ldbcall(leveldb_get, db.handle, opts.handle, k, length(k), olen)
    unsafe_wrap(Array, o, olen[], own=true)
end
function Base.getindex(db::DB, k::AbstractVecOrString, ::Type{String}, opts::ReadOptions)::String
    String(getindex(db, k, Vector{UInt8}, opts))
end
function Base.getindex(db, k::AbstractVecOrString, ::Type{T}; kw...) where {T}
    getindex(db, k, T, ReadOptions(;kw...))
end
Base.getindex(db::DB{K,V}, k::AbstractVecOrString; kw...) where {K,V} = getindex(db, k, V; kw...)

function Base.delete!(db::DB, k::AbstractVecOrString, opts::WriteOptions)
    k = _normalizekeyval(k)
    ldbcall(leveldb_delete, db.handle, opts.handle, k, length(k))
end
Base.delete!(db::DB, k::AbstractVecOrString; kw...) = delete!(db, k, WriteOptions(;kw...))


mutable struct Iterator{R<:IteratorTypes,K<:VecOrString,V<:VecOrString}
    handle::Ptr{leveldb_iterator_t}
    db::DB  # we need this reference to keep from getting GC'd; don't care about types

    function Iterator{R,K,V}(h::Ptr, db::DB) where {R,K,V}
        finalizer(x -> leveldb_iter_destroy(x.handle), new{R,K,V}(h, db))
    end
end

function Iterator{R,K,V}(db::DB, opts::ReadOptions) where {R,K,V}
    isopen(db) || error("tried to create iterator from closed database")
    h = leveldb_create_iterator(db.handle, opts.handle)
    R ∈ typeof.((keys, values, pairs)) || throw(ArgumentError("invalid iterator type $R"))
    o = Iterator{R,K,V}(h, db)
    seekstart(o)  # don't know why they start this out in an invalid state
    o
end

Iterator{R,K,V}(db; kw...) where {R,K,V} = Iterator{R,K,V}(db, ReadOptions(;kw...))
Iterator(db::DB{K,V}, r=pairs; kw...) where {K,V} = Iterator{typeof(r),K,V}(db; kw...)

function Base.show(io::IO, itr::Iterator)
    show(io, typeof(itr))
    print(io, "()")
end

for 𝒻 ∈ (:keys, :values, :pairs)
    @eval Base.$𝒻(db::DB; kw...) = Iterator(db, $𝒻; kw...)
end

function isvalidstate(itr::Iterator)
    _checkopen(itr.db)
    Bool(leveldb_iter_valid(itr.handle))
end

function next!(itr::Iterator)
    _checkopen(itr.db)
    leveldb_iter_next(itr.handle)
    isvalidstate(itr)
end

function prev!(itr::Iterator)
    _checkopen(itr.db)
    leveldb_iter_prev(itr.handle)
    isvalidstate(itr)
end

function Base.seekstart(itr::Iterator)
    _checkopen(itr.db)
    leveldb_iter_seek_to_first(itr.handle)
end
function Base.seekend(itr::Iterator)
    _checkopen(itr.db)
    leveldb_iter_seek_to_last(itr.handle)
end

function Base.seek(itr::Iterator, k::AbstractVecOrString)
    _checkopen(itr.db)
    k = _normalizekeyval(k)
    leveldb_iter_seek(itr.handle, k, length(k))
    isvalidstate(itr)
end

function Base.getkey(itr::Iterator, ::Type{Vector{UInt8}})::Union{Nothing,Vector{UInt8}}
    _checkopen(itr.db)
    isvalidstate(itr) || return nothing
    klen = Ref{Csize_t}()
    k = leveldb_iter_key(itr.handle, klen)  # this apparently borrows k
    GC.@preserve k begin
        o = Vector{UInt8}(undef, klen[])
        unsafe_copyto!(pointer(o), convert(Ptr{UInt8}, k), klen[])
    end
    o
end
function Base.getkey(itr::Iterator, ::Type{String})
    o = getkey(itr, Vector{UInt8})
    isnothing(o) ? o : String(o)
end
Base.getkey(itr::Iterator{R,K,V}) where {R,K,V} = getkey(itr, K)

function getvalue(itr::Iterator, ::Type{Vector{UInt8}})::Union{Nothing,Vector{UInt8}}
    _checkopen(itr.db)
    isvalidstate(itr) || return default
    vlen = Ref{Csize_t}()
    v = leveldb_iter_value(itr.handle, vlen)  # this apparently borrows v
    GC.@preserve v begin
        o = Vector{UInt8}(undef, vlen[])
        unsafe_copyto!(pointer(o), convert(Ptr{UInt8}, v), vlen[])
    end
    o
end
function getvalue(itr::Iterator, ::Type{String})
    o = getvalue(itr, Vector{UInt8})
    isnothing(o) ? o : String(o)
end
getvalue(itr::Iterator{R,K,V}) where {R,K,V} = getvalue(itr, V)

function getpair(itr::Iterator, ::Type{Pair{K,V}}) where {K,V}
    k = getkey(itr, K)
    isnothing(k) && return nothing
    k => getvalue(itr, V)
end
getpair(itr::Iterator{R,K,V}) where {R,K,V} = getpair(itr, Pair{K,V})


Base.IteratorSize(::Type{<:Iterator}) = Base.SizeUnknown()
Base.IteratorEltype(::Type{<:Iterator}) = Base.HasEltype()

Base.eltype(::Type{<:Iterator{typeof(keys),K,V}}) where {K,V} = K
Base.eltype(::Type{<:Iterator{typeof(values),K,V}}) where {K,V} = V
Base.eltype(::Type{<:Iterator{typeof(pairs),K,V}}) where {K,V} = Pair{K,V}

getel(itr::Iterator{typeof(keys),K,V}) where {K,V} = getkey(itr)
getel(itr::Iterator{typeof(values),K,V}) where {K,V} = getvalue(itr)
getel(itr::Iterator{typeof(pairs),K,V}) where {K,V} = getpair(itr)

# state is whether we are starting over
function Base.iterate(itr::Iterator{R,K,V}, state=true) where {R,K,V}
    state && seekstart(itr)
    if state ? isvalidstate(itr) : next!(itr)
        (getel(itr), false)
    else
        nothing
    end
end


end # module LevelDB
