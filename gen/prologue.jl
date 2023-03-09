
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
