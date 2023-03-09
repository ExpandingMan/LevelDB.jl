module Lib

using LevelDB_jll
export LevelDB_jll

using CEnum


function ldbcall(f, a...)
    err = Ref{Ptr{Cchar}}(C_NULL)
    o = f(a..., err)
    if err[] ≠ C_NULL
        str = unsafe_string(err[])
        leveldb_free(err[])
        isempty(str) || error(str)
    end
    o
end

mutable struct leveldb_t end

mutable struct leveldb_cache_t end

mutable struct leveldb_comparator_t end

mutable struct leveldb_env_t end

mutable struct leveldb_filelock_t end

mutable struct leveldb_filterpolicy_t end

mutable struct leveldb_iterator_t end

mutable struct leveldb_logger_t end

mutable struct leveldb_options_t end

mutable struct leveldb_randomfile_t end

mutable struct leveldb_readoptions_t end

mutable struct leveldb_seqfile_t end

mutable struct leveldb_snapshot_t end

mutable struct leveldb_writablefile_t end

mutable struct leveldb_writebatch_t end

mutable struct leveldb_writeoptions_t end

function leveldb_open(options, name, errptr)
    @ccall leveldb.leveldb_open(options::Ptr{leveldb_options_t}, name::Ptr{Cchar}, errptr::Ptr{Ptr{Cchar}})::Ptr{leveldb_t}
end

function leveldb_close(db)
    @ccall leveldb.leveldb_close(db::Ptr{leveldb_t})::Cvoid
end

function leveldb_put(db, options, key, keylen, val, vallen, errptr)
    @ccall leveldb.leveldb_put(db::Ptr{leveldb_t}, options::Ptr{leveldb_writeoptions_t}, key::Ptr{Cchar}, keylen::Csize_t, val::Ptr{Cchar}, vallen::Csize_t, errptr::Ptr{Ptr{Cchar}})::Cvoid
end

function leveldb_delete(db, options, key, keylen, errptr)
    @ccall leveldb.leveldb_delete(db::Ptr{leveldb_t}, options::Ptr{leveldb_writeoptions_t}, key::Ptr{Cchar}, keylen::Csize_t, errptr::Ptr{Ptr{Cchar}})::Cvoid
end

function leveldb_write(db, options, batch, errptr)
    @ccall leveldb.leveldb_write(db::Ptr{leveldb_t}, options::Ptr{leveldb_writeoptions_t}, batch::Ptr{leveldb_writebatch_t}, errptr::Ptr{Ptr{Cchar}})::Cvoid
end

function leveldb_get(db, options, key, keylen, vallen, errptr)
    @ccall leveldb.leveldb_get(db::Ptr{leveldb_t}, options::Ptr{leveldb_readoptions_t}, key::Ptr{Cchar}, keylen::Csize_t, vallen::Ptr{Csize_t}, errptr::Ptr{Ptr{Cchar}})::Ptr{Cchar}
end

function leveldb_create_iterator(db, options)
    @ccall leveldb.leveldb_create_iterator(db::Ptr{leveldb_t}, options::Ptr{leveldb_readoptions_t})::Ptr{leveldb_iterator_t}
end

function leveldb_create_snapshot(db)
    @ccall leveldb.leveldb_create_snapshot(db::Ptr{leveldb_t})::Ptr{leveldb_snapshot_t}
end

function leveldb_release_snapshot(db, snapshot)
    @ccall leveldb.leveldb_release_snapshot(db::Ptr{leveldb_t}, snapshot::Ptr{leveldb_snapshot_t})::Cvoid
end

function leveldb_property_value(db, propname)
    @ccall leveldb.leveldb_property_value(db::Ptr{leveldb_t}, propname::Ptr{Cchar})::Ptr{Cchar}
end

function leveldb_approximate_sizes(db, num_ranges, range_start_key, range_start_key_len, range_limit_key, range_limit_key_len, sizes)
    @ccall leveldb.leveldb_approximate_sizes(db::Ptr{leveldb_t}, num_ranges::Cint, range_start_key::Ptr{Ptr{Cchar}}, range_start_key_len::Ptr{Csize_t}, range_limit_key::Ptr{Ptr{Cchar}}, range_limit_key_len::Ptr{Csize_t}, sizes::Ptr{UInt64})::Cvoid
end

function leveldb_compact_range(db, start_key, start_key_len, limit_key, limit_key_len)
    @ccall leveldb.leveldb_compact_range(db::Ptr{leveldb_t}, start_key::Ptr{Cchar}, start_key_len::Csize_t, limit_key::Ptr{Cchar}, limit_key_len::Csize_t)::Cvoid
end

function leveldb_destroy_db(options, name, errptr)
    @ccall leveldb.leveldb_destroy_db(options::Ptr{leveldb_options_t}, name::Ptr{Cchar}, errptr::Ptr{Ptr{Cchar}})::Cvoid
end

function leveldb_repair_db(options, name, errptr)
    @ccall leveldb.leveldb_repair_db(options::Ptr{leveldb_options_t}, name::Ptr{Cchar}, errptr::Ptr{Ptr{Cchar}})::Cvoid
end

function leveldb_iter_destroy(arg1)
    @ccall leveldb.leveldb_iter_destroy(arg1::Ptr{leveldb_iterator_t})::Cvoid
end

function leveldb_iter_valid(arg1)
    @ccall leveldb.leveldb_iter_valid(arg1::Ptr{leveldb_iterator_t})::UInt8
end

function leveldb_iter_seek_to_first(arg1)
    @ccall leveldb.leveldb_iter_seek_to_first(arg1::Ptr{leveldb_iterator_t})::Cvoid
end

function leveldb_iter_seek_to_last(arg1)
    @ccall leveldb.leveldb_iter_seek_to_last(arg1::Ptr{leveldb_iterator_t})::Cvoid
end

function leveldb_iter_seek(arg1, k, klen)
    @ccall leveldb.leveldb_iter_seek(arg1::Ptr{leveldb_iterator_t}, k::Ptr{Cchar}, klen::Csize_t)::Cvoid
end

function leveldb_iter_next(arg1)
    @ccall leveldb.leveldb_iter_next(arg1::Ptr{leveldb_iterator_t})::Cvoid
end

function leveldb_iter_prev(arg1)
    @ccall leveldb.leveldb_iter_prev(arg1::Ptr{leveldb_iterator_t})::Cvoid
end

function leveldb_iter_key(arg1, klen)
    @ccall leveldb.leveldb_iter_key(arg1::Ptr{leveldb_iterator_t}, klen::Ptr{Csize_t})::Ptr{Cchar}
end

function leveldb_iter_value(arg1, vlen)
    @ccall leveldb.leveldb_iter_value(arg1::Ptr{leveldb_iterator_t}, vlen::Ptr{Csize_t})::Ptr{Cchar}
end

function leveldb_iter_get_error(arg1, errptr)
    @ccall leveldb.leveldb_iter_get_error(arg1::Ptr{leveldb_iterator_t}, errptr::Ptr{Ptr{Cchar}})::Cvoid
end

function leveldb_writebatch_create()
    @ccall leveldb.leveldb_writebatch_create()::Ptr{leveldb_writebatch_t}
end

function leveldb_writebatch_destroy(arg1)
    @ccall leveldb.leveldb_writebatch_destroy(arg1::Ptr{leveldb_writebatch_t})::Cvoid
end

function leveldb_writebatch_clear(arg1)
    @ccall leveldb.leveldb_writebatch_clear(arg1::Ptr{leveldb_writebatch_t})::Cvoid
end

function leveldb_writebatch_put(arg1, key, klen, val, vlen)
    @ccall leveldb.leveldb_writebatch_put(arg1::Ptr{leveldb_writebatch_t}, key::Ptr{Cchar}, klen::Csize_t, val::Ptr{Cchar}, vlen::Csize_t)::Cvoid
end

function leveldb_writebatch_delete(arg1, key, klen)
    @ccall leveldb.leveldb_writebatch_delete(arg1::Ptr{leveldb_writebatch_t}, key::Ptr{Cchar}, klen::Csize_t)::Cvoid
end

function leveldb_writebatch_iterate(arg1, state, put, deleted)
    @ccall leveldb.leveldb_writebatch_iterate(arg1::Ptr{leveldb_writebatch_t}, state::Ptr{Cvoid}, put::Ptr{Cvoid}, deleted::Ptr{Cvoid})::Cvoid
end

function leveldb_writebatch_append(destination, source)
    @ccall leveldb.leveldb_writebatch_append(destination::Ptr{leveldb_writebatch_t}, source::Ptr{leveldb_writebatch_t})::Cvoid
end

function leveldb_options_create()
    @ccall leveldb.leveldb_options_create()::Ptr{leveldb_options_t}
end

function leveldb_options_destroy(arg1)
    @ccall leveldb.leveldb_options_destroy(arg1::Ptr{leveldb_options_t})::Cvoid
end

function leveldb_options_set_comparator(arg1, arg2)
    @ccall leveldb.leveldb_options_set_comparator(arg1::Ptr{leveldb_options_t}, arg2::Ptr{leveldb_comparator_t})::Cvoid
end

function leveldb_options_set_filter_policy(arg1, arg2)
    @ccall leveldb.leveldb_options_set_filter_policy(arg1::Ptr{leveldb_options_t}, arg2::Ptr{leveldb_filterpolicy_t})::Cvoid
end

function leveldb_options_set_create_if_missing(arg1, arg2)
    @ccall leveldb.leveldb_options_set_create_if_missing(arg1::Ptr{leveldb_options_t}, arg2::UInt8)::Cvoid
end

function leveldb_options_set_error_if_exists(arg1, arg2)
    @ccall leveldb.leveldb_options_set_error_if_exists(arg1::Ptr{leveldb_options_t}, arg2::UInt8)::Cvoid
end

function leveldb_options_set_paranoid_checks(arg1, arg2)
    @ccall leveldb.leveldb_options_set_paranoid_checks(arg1::Ptr{leveldb_options_t}, arg2::UInt8)::Cvoid
end

function leveldb_options_set_env(arg1, arg2)
    @ccall leveldb.leveldb_options_set_env(arg1::Ptr{leveldb_options_t}, arg2::Ptr{leveldb_env_t})::Cvoid
end

function leveldb_options_set_info_log(arg1, arg2)
    @ccall leveldb.leveldb_options_set_info_log(arg1::Ptr{leveldb_options_t}, arg2::Ptr{leveldb_logger_t})::Cvoid
end

function leveldb_options_set_write_buffer_size(arg1, arg2)
    @ccall leveldb.leveldb_options_set_write_buffer_size(arg1::Ptr{leveldb_options_t}, arg2::Csize_t)::Cvoid
end

function leveldb_options_set_max_open_files(arg1, arg2)
    @ccall leveldb.leveldb_options_set_max_open_files(arg1::Ptr{leveldb_options_t}, arg2::Cint)::Cvoid
end

function leveldb_options_set_cache(arg1, arg2)
    @ccall leveldb.leveldb_options_set_cache(arg1::Ptr{leveldb_options_t}, arg2::Ptr{leveldb_cache_t})::Cvoid
end

function leveldb_options_set_block_size(arg1, arg2)
    @ccall leveldb.leveldb_options_set_block_size(arg1::Ptr{leveldb_options_t}, arg2::Csize_t)::Cvoid
end

function leveldb_options_set_block_restart_interval(arg1, arg2)
    @ccall leveldb.leveldb_options_set_block_restart_interval(arg1::Ptr{leveldb_options_t}, arg2::Cint)::Cvoid
end

function leveldb_options_set_max_file_size(arg1, arg2)
    @ccall leveldb.leveldb_options_set_max_file_size(arg1::Ptr{leveldb_options_t}, arg2::Csize_t)::Cvoid
end

@cenum var"##Ctag#313"::UInt32 begin
    leveldb_no_compression = 0
    leveldb_snappy_compression = 1
end

function leveldb_options_set_compression(arg1, arg2)
    @ccall leveldb.leveldb_options_set_compression(arg1::Ptr{leveldb_options_t}, arg2::Cint)::Cvoid
end

function leveldb_comparator_create(state, destructor, compare, name)
    @ccall leveldb.leveldb_comparator_create(state::Ptr{Cvoid}, destructor::Ptr{Cvoid}, compare::Ptr{Cvoid}, name::Ptr{Cvoid})::Ptr{leveldb_comparator_t}
end

function leveldb_comparator_destroy(arg1)
    @ccall leveldb.leveldb_comparator_destroy(arg1::Ptr{leveldb_comparator_t})::Cvoid
end

function leveldb_filterpolicy_create(state, destructor, create_filter, key_may_match, name)
    @ccall leveldb.leveldb_filterpolicy_create(state::Ptr{Cvoid}, destructor::Ptr{Cvoid}, create_filter::Ptr{Cvoid}, key_may_match::Ptr{Cvoid}, name::Ptr{Cvoid})::Ptr{leveldb_filterpolicy_t}
end

function leveldb_filterpolicy_destroy(arg1)
    @ccall leveldb.leveldb_filterpolicy_destroy(arg1::Ptr{leveldb_filterpolicy_t})::Cvoid
end

function leveldb_filterpolicy_create_bloom(bits_per_key)
    @ccall leveldb.leveldb_filterpolicy_create_bloom(bits_per_key::Cint)::Ptr{leveldb_filterpolicy_t}
end

function leveldb_readoptions_create()
    @ccall leveldb.leveldb_readoptions_create()::Ptr{leveldb_readoptions_t}
end

function leveldb_readoptions_destroy(arg1)
    @ccall leveldb.leveldb_readoptions_destroy(arg1::Ptr{leveldb_readoptions_t})::Cvoid
end

function leveldb_readoptions_set_verify_checksums(arg1, arg2)
    @ccall leveldb.leveldb_readoptions_set_verify_checksums(arg1::Ptr{leveldb_readoptions_t}, arg2::UInt8)::Cvoid
end

function leveldb_readoptions_set_fill_cache(arg1, arg2)
    @ccall leveldb.leveldb_readoptions_set_fill_cache(arg1::Ptr{leveldb_readoptions_t}, arg2::UInt8)::Cvoid
end

function leveldb_readoptions_set_snapshot(arg1, arg2)
    @ccall leveldb.leveldb_readoptions_set_snapshot(arg1::Ptr{leveldb_readoptions_t}, arg2::Ptr{leveldb_snapshot_t})::Cvoid
end

function leveldb_writeoptions_create()
    @ccall leveldb.leveldb_writeoptions_create()::Ptr{leveldb_writeoptions_t}
end

function leveldb_writeoptions_destroy(arg1)
    @ccall leveldb.leveldb_writeoptions_destroy(arg1::Ptr{leveldb_writeoptions_t})::Cvoid
end

function leveldb_writeoptions_set_sync(arg1, arg2)
    @ccall leveldb.leveldb_writeoptions_set_sync(arg1::Ptr{leveldb_writeoptions_t}, arg2::UInt8)::Cvoid
end

function leveldb_cache_create_lru(capacity)
    @ccall leveldb.leveldb_cache_create_lru(capacity::Csize_t)::Ptr{leveldb_cache_t}
end

function leveldb_cache_destroy(cache)
    @ccall leveldb.leveldb_cache_destroy(cache::Ptr{leveldb_cache_t})::Cvoid
end

function leveldb_create_default_env()
    @ccall leveldb.leveldb_create_default_env()::Ptr{leveldb_env_t}
end

function leveldb_env_destroy(arg1)
    @ccall leveldb.leveldb_env_destroy(arg1::Ptr{leveldb_env_t})::Cvoid
end

function leveldb_env_get_test_directory(arg1)
    @ccall leveldb.leveldb_env_get_test_directory(arg1::Ptr{leveldb_env_t})::Ptr{Cchar}
end

function leveldb_free(ptr)
    @ccall leveldb.leveldb_free(ptr::Ptr{Cvoid})::Cvoid
end

function leveldb_major_version()
    @ccall leveldb.leveldb_major_version()::Cint
end

function leveldb_minor_version()
    @ccall leveldb.leveldb_minor_version()::Cint
end

# exports
const PREFIXES = ["leveldb_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
