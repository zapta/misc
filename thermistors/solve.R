#!/usr/local/bin/Rscript

options(warn = 1)

# Calibration temperatues and resistances
t0 = c(20, 100, 200, 280)
r0 = c(100000, 90000, 80000, 75000)

# Map resistance to temp using coeficients abc=[a, b, c].
# See https://en.wikipedia.org/wiki/Steinhart%E2%80%93Hart_equation
r2t <- function(r, abc) {
  lnr = log(r)
  1/(abc[1] + abc[2]*lnr + abc[3]*(lnr^3)) 
}

# Compute rms error for coeficients abc=[a, b, c]
err <- function(abc) {
 t = sapply(r0, r2t, abc, simplify="array")
 sqrt(mean((t - t0)^2))
}

# Starting point of a,b,c for the minimization.
abc0 = c(1, 1, 1)

# Find solution [a, b, c] which minimizes the error relative to t0.
solution = nlm(err, abc0)
print(solution)
