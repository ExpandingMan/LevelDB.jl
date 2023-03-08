
function ldbcall(f, a...)
    err = Ref{Ref{Cstring}}()
    o = f(a..., err)
    err = unsafe_string(err[])
    isempty(err) || error(err)
    o
end
