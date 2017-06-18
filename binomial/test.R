#!/usr/local/bin/Rscript

options(warn = 1)

# Noation
# m = sample size
# k = fraction of 1's in original population

# Indicates if to display percentage relative to golden value.
is_relative <- FALSE

# Control plot range.
max_error <- 14
max_density <- 0.6

# m, k, of  plots
plots <- list(
  c(1000,  0.05),
  c(1000,  0.20),
  c(1000,  0.35),
  c(1000,  0.50),
  c(1000,  0.65),
  c(1000,  0.80),
  c(1000,  0.95)

#  c(100,  0.1),
#  c(200,  0.1),
#  c(500,  0.1),
#  c(1000, 0.1),
#  c(2000, 0.1),
#  c(5000, 0.1)
)

color_pallet <- rainbow(length(plots))

# Shift vector values by n positions, right (positive n)
# or left (negative n).
shift <- function(x, n) {
  l <- length(x)
  if (n > 0) {
    y <- c(rep(0, n), x[0:(l-n)])
  } else if (n < 0) {
    y <- c(x[(-n+1):l], rep(0, -n))
  } else {
    y <- x
  }
  return(y)
}

# Given a vector with a binomial distribution values (whose sum is 1),
# find the smaller range of indexes that captures a sum not below r.
# r is a fraction in the range [0, 1].
# Returns [min_index, max_index].
percentile_range <- function(x, r) {
  i <- 1
  j <- length(x)
  while(i <= j) {
    if (x[i] < x[j]) {
      v <- x[i] 
      idx <- i
      i = i + 1
    } else {
      v <- x[j]
      idx <- j
      j = j - 1
    }
    if ((sum(x) - v) < r) {
      break
    }
    x[idx] <- 0
  }
  return(c(i, j))
}

# Given a vector with values of a binomial distribution, 
# find the minimal range whose sum is at least r and 
# replace values outside of the range with NAN.
keep_percentile <- function(x, r) {
  range <- percentile_range(x, r)
  x[1: (range[1]-1)] <- NA
  x[(range[2]+1):length(x)] <- NA
  return (x)
}

# Returns m+1 density values with sum of 1.
# k is the fraction of 1's in the original 
# distribution.
distribution <- function(m, k){
  x <- dbinom(0:m, size=m, prob=k)
  if (is_relative) {
    n = round(m/2 - k*m)
    x <- shift(x, n)
  }
  return(x)
}

#png('rplot.png', width = 800, height = 600)
X11(width=12, height=7)

plot(0, 0, 
    xlim = if (is_relative) c(-max_error, max_error) else c(0, 100),
    ylim = c(0, max_density),
    xlab = "Percentage Estimation (Binomial Distribution)",
    ylab = "Density",
    xaxs="i",
    yaxs="i",
    axes = FALSE,
    type = "n")

if (is_relative) {
  axis(side = 1, at = seq(-max_error, max_error, 2), tck=1, lty=3, yaxs="i")
  axis(side = 1, at = seq(-max_error, max_error, 1), labels=FALSE)
} else {
  axis(side = 1, at = seq(0, 100, 5), tck=1, lty=3, yaxs="i")
}

# We accomulate legend text and colors as we plot
legends <- c()
colors  <- c()

for (i in 1:length(plots)) {
  p <- plots[[i]]
  cat("Plotting ", p, "\n")

  m <- as.numeric(p[1])
  k <- as.numeric(p[2])
  col <- color_pallet[i]

  legends <- c(legends, sprintf(" K=%.2f   M=%d", k, as.integer(m)))
  colors <- c(colors, col)

  if (is_relative) {
    xs <- seq(from=-50, to=50, by=100/m)
  } else {
    xs <- seq(from=0, to=100, by=100/m)
  }

  dist <- distribution(m, k)
  yscale = m/100

  ys <- keep_percentile(dist, 0.99)
  lines(xs, yscale*ys, type = "l", col=col, lwd=2)

  ys <- keep_percentile(dist, 0.95)
  lines(xs, yscale*ys, type = "l", col=col, lwd=5)
}

legend("topright", 
   col=colors,
   bg="white",
   lwd=4,
   legend=legends)

legend("topleft", 
   bg="white",
   lwd=c(8, 2),
   legend=c("95 percentile", "99 percentile"))


message("Press return to exit...")
invisible(readLines("stdin", n<-1))
