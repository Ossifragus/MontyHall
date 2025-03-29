## least squares
set.seed(1)
n = 10^4
p = 10^3
X = matrix(rnorm(n * p), n, p)
beta = rep(1, p)
Y = X %*% beta + rnorm(n)

# the worst
system.time(
    solve(t(X) %*% X) %*% t(X) %*% Y
)

# can be better
system.time(
    solve(t(X) %*% X) %*% (t(X) %*% Y)
)

# should be this way
system.time(
    solve(t(X) %*% X, t(X) %*% Y)
)

system.time(lm.fit(X, Y))

## weighted least squares
set.seed(1)
n = 10^4
p = 10^2
X = matrix(rnorm(n * p), n, p)
beta = rep(1, p)
Y = X %*% beta + rnorm(n)

w = runif(n)
W = diag(w)

# never do this
system.time(solve(t(X) %*% W %*% X, t(X) %*% W %*% Y))

# do it this way
system.time({
    wX = w * X
    solve(t(X) %*% wX, t(wX) %*% Y)
})

## leverage scores

# never do this
system.time({
    L1 = diag(X %*% solve(t(X) %*% X, t(X)))
})

# try the following two
library(expm)
system.time({
    XXrt <- sqrtm(t(X) %*% X)
    L2 = colSums((solve(XXrt, t(X))^2))
})

system.time({L3 <- rowSums(svd(X)$u^2)})
