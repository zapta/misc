#!/usr/local/bin/Rscript

options(warn = 1)

# Population size. Doesn't affect the distribution (assuming >> M).
N <- 10000

# The fraction of the N instances that are '1' (the reset are zero).
# This is also the golden percentage which we try to estimate.
K <- 0.25

# Size of the random subsample of N.
M <- 500

X11(width=8, height=4)

x <- dbinom(0:M, size=M, prob=K)

# Move 0 error to the center of the graph. Range [-L/2, L/2].
#shift_n = round(L/2 - K*L)
#x <- c(rep(0, shift_n), x[0:(L-shift_n)])

plot(x, names.arg=0:M, type="l")

message("Press return to exit...")
invisible(readLines("stdin", n<-1))
