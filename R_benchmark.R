library(microbenchmark)  						 
A <- as.matrix(runif(1000000, 0,10),ncol=1000)
B <- as.matrix(runif(1000000, 0,10),ncol=1000)
colnames(A) <- colnames(B) <- NULL	
system.time(
Z <- microbenchmark(A + 2, A - 2, A * 2, A / 2, A + B, A - B, A * B, A / B, A ^ 2, sqrt(A), control=list(order = 'block'), times = 1000L))
Z