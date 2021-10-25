library(ggplot2)
library(jsonlite)

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
p <- p + theme_bw()? + facet_wrap(~epochs, nrow=1)
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







readGenLog <- function(filename) {
  alg <- strsplit(filename, "[.]")[[1]][2]
  init <- strsplit(filename, "[.]")[[1]][3]
  epochs <- strsplit(filename, "[.]")[[1]][4]
  raw_log <- read.csv(filename, sep="\t", header=FALSE)
  colnames(raw_log) <- c("ngen", "evals", "mean", "std", "min", "max")
  raw_log$algorithm <- alg
  raw_log$init <- init
  raw_log$epochs <- epochs
  raw_log$seed <- unlist(lapply(1:100, function(x){ rep(x, 105)}))
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
        tmp <- log[which(log$ngen==i & log$algorithm==alg & log$init==init & log$epochs==epochs), c("mean", "max")]
        meanLog <- rbind(meanLog, data.frame(algorithm=alg, init=init, epochs=epochs, ngen=i, mean=mean(tmp$mean), std=sd(tmp$mean), max=mean(tmp$max), stdmax=sd(tmp$max)) )
      }
    }
  }
}

p <- ggplot(meanLog, aes(x=ngen, y=mean)) + geom_line(aes(color=init))
p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2)
p <- p + ylab("Mean population validation accuracy") + xlab("Generation")
p

p <- ggplot(meanLog, aes(x=ngen, y=max)) + geom_line(aes(color=init))
p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2)
p <- p + ylab("Mean max population validation accuracy") + xlab("Generation")
p
