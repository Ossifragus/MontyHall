# least squares

using Random
Random.seed!(1)
n, p = 10^4, 10^3
X = randn(n, p);
β = ones(p);
Y = X * β .+ randn(n);

# the first time running is slow
@time β̂ = X'X \ X'Y;
@time β̂ = X'X \ X'Y;

# weighted least squares

n, p = 10^4, 10^2
X = randn(n, p);
β = ones(p);
Y = X * β .+ randn(n);
w = rand(n)

@time begin
    wX = X .* w
    β̂w = wX'X \ wX'Y
end;

function wls(X, Y, w)
    wX = X .* w
    β̂w = wX'X \ wX'Y
end

# pre allocate wX to avoid memory allocation
wX = similar(X);
function wls!(X, Y, w, wX)
    wX .= X .* w
    β̂w = wX'X \ wX'Y
end

rpt = 10
@time for i in 1:rpt β̂w = wls(X, Y, w) end
@time for i in 1:rpt β̂w = wls!(X, Y, w, wX) end

# leverage scores
using LinearAlgebra
# @time L1 = diag(X / (X'X) * X');
@time L2 = sum(abs2, X / √(X'X), dims=2);
@time L3 = sum(abs2, svd(X).U, dims=2);
