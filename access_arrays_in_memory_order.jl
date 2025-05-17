# Row-major order is used in C/C++, SAS, NumPy (Python)
# Column-major order is used in Fortran, MATLAB, Julia, R

using Pkg; Pkg.activate(".")
using Chairmarks

function mysum(M)
    s = 0.0
    n = size(M)[1]
    for i in 1:n, j in 1:n
        s += M[i, j]
    end
    return s
end

n = 10^4
M = rand(n, n);

@b mysum($M)

function mysum2(M)
    s = 0.0
    n = size(M)[1]
    for j in 1:n, i in 1:n
        s += M[i, j]
    end
    return s
end

@b mysum2($M)
