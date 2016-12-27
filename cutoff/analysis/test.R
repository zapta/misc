#!/usr/local/bin/Rscript

options(warn = 1)

# Compute moving average function. Returns vector of same length.
ma <- function(arr, n=15){
  res = arr
  for(i in n:length(arr)){
    res[i] = mean(arr[(i-n+1):i])
  }
  res
}

# Compute RC low pass. Return vector of same length.
# K is the change proportion per time tick (lower is slower).
rc <- function(arr, k=0.01){
  res = arr
  for(i in 2:length(arr)){
    res[i] = res[i-1]+k*(arr[i]-res[i-1])
  }
  res
}

sub_sample = 100
k1 = 1/16
k2 = 1/256

# Car start voltage samples at 1Khz rate.
raw_sample <- read.table("cranking.data", header = FALSE)
#raw_sample <- read.table("power_on.data", header = FALSE)
#raw_sample <- read.table("power_off.data", header = FALSE)

raw_tick_time = 0.001

total_time=length(raw_sample)/1000

# Convert dataframe to numeric vector
raw <- raw_sample[,1]

# Subsample 1Khz to 200Hz
#cat("raw length: ", length(raw), "\n")

s0 <- raw[seq(1, length(raw), 5)]
#cat("s0 length: ", length(s0), "\n")

tick_time = 0.001 * length(raw)/length(s0)
cat("tick time: ", tick_time*1000, " ms\n")

ts = seq(along.with=s0)*tick_time
#print(ts)

# Fast filter
s1=rc(s0, k1)
#cat("s1 length: ", length(s1), "\n")

# Slow filter
s2=rc(s0, k2)
#cat("s2 length: ", length(s2), "\n")

# Diff
s3 = s1 - s2
#cat("s3 length: ", length(s3), "\n")

# Clip 
s4 = s3
for(i in 1:length(s4)){
  if (s4[i] > 1) {
    s4[i] = 1
  } else if (s4[i] < -1) {
    s4[i] = -1
  } else {
    s4[i] = 0
  }
}
#cat("s4 length: ", length(s4), "\n")

X11(width=12, height=5)
plot(ts, s0, type="l") 
lines(ts, s1, type="l", col="red") 
lines(ts, s2, type="l", col="blue") 

X11(width=12, height=5)
plot(ts, s3, type="l", col="blue") 
abline(h=-1)
abline(h=1)
lines(ts, s4, type="l", col="red", lwd=2) 

message("Press return to exit...")
invisible(readLines("stdin", n=1))
