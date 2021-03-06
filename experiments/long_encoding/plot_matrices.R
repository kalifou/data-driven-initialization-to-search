library(ggplot2)
library(jsonlite)
#require(reshape2)

if (!require(reshape2)) install.packages('reshape2')
library(reshape2)

library(gridExtra)

setwd("~/git/nasbench/experiments/")



readSummaryLog <- function(filename) {
  raw_txt <- readLines(filename)
  alg <- strsplit(filename, "[.]")[[1]][2]
  init <- strsplit(filename, "[.]")[[1]][3]
  results <- data.frame()
  for(i in 1:100) {
    raw <- fromJSON(strsplit(raw_txt[i], "INFO")[[1]][2])
    results <- rbind(results, data.frame(algorithm=alg, init=init, epochs=raw$epochs, test_accuracy=raw$test_accuracy))
  }
  return(results)
}

results <- data.frame()
results <- rbind(results, readSummaryLog("summary.GA.rand.36.log"))
results <- rbind(results, readSummaryLog("summary.GA.rand.108.log"))
results <- rbind(results, readSummaryLog("summary.EA.rand.36.log"))
results <- rbind(results, readSummaryLog("summary.EA.rand.108.log"))

results <- rbind(results, readSummaryLog("summary.GA.centroids.36.log"))
results <- rbind(results, readSummaryLog("summary.GA.centroids.108.log"))
results <- rbind(results, readSummaryLog("summary.EA.centroids.36.log"))
results <- rbind(results, readSummaryLog("summary.EA.centroids.108.log"))

results$epochs <- as.factor(results$epochs)
results$init <- as.factor(results$init)

p <- ggplot(results, aes(x=algorithm, y=test_accuracy)) + geom_boxplot(aes(fill=init)) 
p <- p + theme_bw() + facet_wrap(~epochs, nrow=1)
p <- p + ylab("Test accuracy") + xlab("Algorithm")
p


wilcox.test(
  results[which(results$algorithm=="GA" & results$epochs==36 & results$init=="rand"), c("test_accuracy")],
  results[which(results$algorithm=="GA" & results$epochs==36 & results$init=="centroids"), c("test_accuracy")])
wilcox.test(
  results[which(results$algorithm=="GA" & results$epochs==108 & results$init=="rand"), c("test_accuracy")],
  results[which(results$algorithm=="GA" & results$epochs==108 & results$init=="centroids"), c("test_accuracy")])

wilcox.test(
  results[which(results$algorithm=="EA" & results$epochs==36 & results$init=="rand"), c("test_accuracy")],
  results[which(results$algorithm=="EA" & results$epochs==36 & results$init=="centroids"), c("test_accuracy")])
wilcox.test(
  results[which(results$algorithm=="EA" & results$epochs==108 & results$init=="rand"), c("test_accuracy")],
  results[which(results$algorithm=="EA" & results$epochs==108 & results$init=="centroids"), c("test_accuracy")])







readGenLog <- function(filename, ngen=105) {
  alg <- strsplit(filename, "[.]")[[1]][2]
  init <- strsplit(filename, "[.]")[[1]][3]
  epochs <- strsplit(filename, "[.]")[[1]][4]
  raw_log <- read.csv(filename, sep="\t", header=FALSE)
  colnames(raw_log) <- c("ngen", "evals", "mean", "std", "min", "max")
  raw_log$algorithm <- alg
  raw_log$init <- init
  raw_log$epochs <- epochs
  raw_log$seed <- unlist(lapply(1:100, function(x){ rep(x, ngen)}))
  return(raw_log)
}

log <- data.frame()
log <- rbind(log, readGenLog("log.GA.rand.36.log"))
log <- rbind(log, readGenLog("log.GA.rand.108.log"))
log <- rbind(log, readGenLog("log.EA.rand.36.log"))
log <- rbind(log, readGenLog("log.EA.rand.108.log"))

log <- rbind(log, readGenLog("log.GA.centroids.36.log"))
log <- rbind(log, readGenLog("log.GA.centroids.108.log"))
log <- rbind(log, readGenLog("log.EA.centroids.36.log"))
log <- rbind(log, readGenLog("log.EA.centroids.108.log"))


meanLog <- data.frame()
for(alg in c("GA", "EA")) {
  for(init in c("rand", "centroids")) {
    for(epochs in c(36, 108)) {
      for(i in 0:104) {
        tmp <- log[which(log$ngen==i & log$algorithm==alg & log$init==init & log$epochs==epochs), c("mean", "max", "min")]
        meanLog <- rbind(meanLog, data.frame(algorithm=alg, init=init, epochs=epochs, ngen=i, mean=mean(tmp$mean), std=sd(tmp$mean), min=mean(tmp$min), max=mean(tmp$max), stdmax=sd(tmp$max)) )
      }
    }
  }
}

meanLog$evals <- meanLog$ngen * 19 + 19

p <- ggplot(meanLog, aes(x=evals, y=mean)) + geom_line(aes(color=init))
p <- p + geom_ribbon(aes(x=evals, y=mean, ymin=(mean-std), ymax=(mean+std), fill=init), alpha=0.1)
# p <- p + geom_ribbon(aes(x=evals, y=mean, ymin=min, ymax=max, fill=init), alpha=0.1)
p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2)
p <- p + ylab("Mean population validation accuracy") + xlab("Function evaluations")
p

p <- ggplot(meanLog, aes(x=evals, y=max)) + geom_line(aes(color=init))
p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2)
p <- p + ylab("Mean max population validation accuracy") + xlab("Function evaluations")
p








#################################################
"input"
"conv1x1-bn-relu"
"conv3x3-bn-relu"
"maxpool3x3"
"output"

create_matrix <- function() {
  full_adj_matrix <- as.data.frame(array(data=0, dim=c(2+5*3, 2+5*3)))
  colnames(full_adj_matrix) <- c("input", 
    paste("conv1x1-bn-relu", seq(1, 5, 1), sep="_"), 
    paste("conv3x3-bn-relu", seq(1, 5, 1), sep="_"), 
    paste("maxpool3x3", seq(1, 5, 1), sep="_"), 
    "output")
  rownames(full_adj_matrix) <- colnames(full_adj_matrix)
  return(full_adj_matrix)
}

expand_matrix <- function(centroid) {
  full_adj_matrix <- create_matrix()
  c1 <- 1
  c3 <- 1
  mp <- 1
  ops <- c()
  for(op in centroid[[2]]) {
   if(op == "conv1x1-bn-relu") {
     ops <- c(ops, paste(op, c1, sep="_"))
     c1 <- c1 + 1
   } else if (op == "conv3x3-bn-relu") {
     ops <- c(ops, paste(op, c3, sep="_"))
     c3 <- c3 + 1
   } else if (op == "maxpool3x3") {
     ops <- c(ops, paste(op, mp, sep="_"))
     mp <- mp + 1
   } else {
     ops <- c(ops, op)
   }
  }
    
  adj <- as.data.frame(centroid[[1]])
  colnames(adj) <- ops
  rownames(adj) <- ops
  
  for(x in ops) {
    for(y in ops) {
      full_adj_matrix[x, y] <- adj[x, y] + full_adj_matrix[x, y]
    }
  }
  return(full_adj_matrix)
}

plotCentroids <- function(centroids, high="black", title="Map") {
  exp_adj_matrix <- create_matrix()
  for(centroid in centroids) {
    exp_adj_matrix <- exp_adj_matrix + expand_matrix(centroid)
  }
  
  rownames(exp_adj_matrix) <- paste(letters[1:17], rownames(exp_adj_matrix), sep="_")
  colnames(exp_adj_matrix) <- rownames(exp_adj_matrix)
  
  df <- melt(as.matrix(exp_adj_matrix))
  
  p <- ggplot(df, aes(Var2, Var1, fill=value)) + geom_tile(color="white", lwd=0.5)
  p <- p + theme_bw() + scale_fill_gradient(low = "white", high = high)
  p <- p + xlab("Out") + ylab("In")
  p <- p + theme(legend.position = "none", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  p <- p + ggtitle(title)
  return(p) 
}


centroids19 <- fromJSON("../../analysis/centroids_N27.json")
c_19 <- plotCentroids(centroids19, high="black") + theme(text = element_text(size = 13))        

centroids13 <- fromJSON("../../analysis/centroids_N13_binary.json")
c_13 <- plotCentroids(centroids13, high="black") + theme(text = element_text(size = 13))        

grid.arrange(c_19, c_13, nrow=1)
#################################################
"input"
"conv1x1-bn-relu"
"conv3x3-bn-relu"
"maxpool3x3"
"output"

summaryLog2Matrices <- function(filename) {
  raw_txt <- readLines(filename)
  alg <- strsplit(filename, "[.]")[[1]][2]
  init <- strsplit(filename, "[.]")[[1]][3]
  results <- list()
  for(i in 1:100) {
    raw <- fromJSON(strsplit(raw_txt[i], "INFO")[[1]][2])
    sol_vector <- as.numeric(raw$solution[1:21])
    sol_ops <- c("input", raw$solution[22:26], "output")
    adj_matrix <- matrix(0, nrow=7, ncol=7)
    adj_matrix[upper.tri(adj_matrix)] <- sol_vector
    solution <- list(adj_matrix, sol_ops)
    results <- c(results, list(solution))
  }
  return(results)
}

summaryLog2MatricesV2 <- function(filename) {
  raw_txt <- readLines(filename)
  alg <- strsplit(filename, "[.]")[[1]][2]
  init <- strsplit(filename, "[.]")[[1]][3]
  results <- list()
  for(i in 1:100) {
    raw <- fromJSON(strsplit(raw_txt[i], "INFO")[[1]][2])
    adj_op_bk <- sum(sapply(1:length(raw$solution), function(x) {
      is.character(raw$solution[[x]])
    }))
    adj_matrix <- sapply(1:(length(raw$solution) - adj_op_bk), function(x) {
      unlist(raw$solution[[x]])
    })
    adj_matrix <- t(adj_matrix)
    ops <- sapply((length(raw$solution) - adj_op_bk + 1):length(raw$solution), function(x) {
      unlist(raw$solution[[x]])
    })
    sol_ops <- c("input", ops, "output")
    solution <- list(adj_matrix, sol_ops)
    results <- c(results, list(solution))
  }
  return(results)
}




setwd("~/git/nasbench/experiments/summaries_long")

ga_rand_36 <- summaryLog2Matrices("summary.GA.rand.36.log")
p1_1 <- plotCentroids(ga_rand_36, high="red", title="GA rand 36")

ga_centroids_36 <- summaryLog2Matrices("summary.GA.centroids.36.log")
p1_2 <- plotCentroids(ga_centroids_36, high="green", title="GA centroids 36")

ga_lhs_36 <- summaryLog2Matrices("summary.GA.lhs.36.log")
p1_3 <- plotCentroids(ga_lhs_36, high="blue", title="GA LHS 36")

grid.arrange(p1_1, p1_2, p1_3, nrow=1)




ga_rand_108 <- summaryLog2Matrices("summary.GA.rand.108.log")
p2_1 <- plotCentroids(ga_rand_108, high="red", title="GA rand 108")

ga_centroids_108 <- summaryLog2Matrices("summary.GA.centroids.108.log")
p2_2 <- plotCentroids(ga_centroids_108, high="green", title="GA centroids 108")

ga_lhs_108 <- summaryLog2Matrices("summary.GA.lhs.108.log")
p2_3 <- plotCentroids(ga_lhs_108, high="blue", title="GA centroids 108")

grid.arrange(p2_1, p2_2, p2_3, nrow=1)




ea_rand_36 <- summaryLog2Matrices("summary.EA.rand.36.log")
p3_1 <- plotCentroids(ea_rand_36, high="red", title="EA rand 36")

ea_centroids_36 <- summaryLog2Matrices("summary.EA.centroids.36.log")
p3_2 <- plotCentroids(ea_centroids_36, high="green", title="EA centroids 36")

ea_lhs_36 <- summaryLog2Matrices("summary.EA.lhs.36.log")
p3_3 <- plotCentroids(ea_lhs_36, high="blue", title="EA LHS 36")

grid.arrange(p3_1, p3_2, p3_3, nrow=1)




ea_rand_108 <- summaryLog2Matrices("summary.EA.rand.108.log")
p4_1 <- plotCentroids(ea_rand_108, high="red", title="EA rand 108")

ea_centroids_108 <- summaryLog2Matrices("summary.EA.centroids.108.log")
p4_2 <- plotCentroids(ea_centroids_108, high="green", title="EA centroids 108")

ea_lhs_108 <- summaryLog2Matrices("summary.EA.lhs.108.log")
p4_3 <- plotCentroids(ea_lhs_108, high="blue", title="EA LHS 108")

grid.arrange(p4_1, p4_2, p4_3, nrow=1)



ae_rand_36 <- summaryLog2MatricesV2("summary.AgingEvol.rand.36.log")
p5_1 <- plotCentroids(ae_rand_36, high="red", title="Aging Evo rand 36")

ae_centroids_36 <- summaryLog2MatricesV2("summary.AgingEvol.centroids.36.log")
p5_2 <- plotCentroids(ae_centroids_36, high="green", title="Aging Evo centroids 36")

ae_lhs_36 <- summaryLog2MatricesV2("summary.AgingEvol.lhs.36.log")
p5_3 <- plotCentroids(ae_lhs_36, high="blue", title="Aging Evo LHS 36")

#grid.arrange(p5_1, p5_2, p5_3, nrow=1)



ae_rand_108 <- summaryLog2MatricesV2("summary.AgingEvol.rand.108.log")
p6_1 <- plotCentroids(ae_rand_108, high="red", title="Aging Evo rand 108")

ae_centroids_108 <- summaryLog2MatricesV2("summary.AgingEvol.centroids.108.log")
p6_2 <- plotCentroids(ae_centroids_108, high="green", title="Aging Evo centroids 108")

ae_lhs_108 <- summaryLog2MatricesV2("summary.AgingEvol.lhs.108.log")
p6_3 <- plotCentroids(ae_lhs_108, high="blue", title="Aging Evo LHS 108")

grid.arrange(p6_1, p6_2, p6_3, nrow=1)




grid.arrange(p1_1, p3_1, p5_1, p1_2, p3_2, p5_2, p1_3, p3_3,  p5_3, nrow=3)


grid.arrange(p2_1, p4_1, p6_1, p2_2, p4_2, p6_2, p2_3, p4_3, p6_3, nrow=3)
