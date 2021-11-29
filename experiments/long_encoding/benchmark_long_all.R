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
results <- rbind(results, readSummaryLog("summary.AgingEvol.rand.36.log"))
results <- rbind(results, readSummaryLog("summary.AgingEvol.rand.108.log"))

results <- rbind(results, readSummaryLog("summary.GA.centroids.36.log"))
results <- rbind(results, readSummaryLog("summary.GA.centroids.108.log"))
results <- rbind(results, readSummaryLog("summary.EA.centroids.36.log"))
results <- rbind(results, readSummaryLog("summary.EA.centroids.108.log"))
results <- rbind(results, readSummaryLog("summary.AgingEvol.centroids.36.log"))
results <- rbind(results, readSummaryLog("summary.AgingEvol.centroids.108.log"))

results <- rbind(results, readSummaryLog("summary.GA.lhs.36.log"))
results <- rbind(results, readSummaryLog("summary.GA.lhs.108.log"))
results <- rbind(results, readSummaryLog("summary.EA.lhs.36.log"))
results <- rbind(results, readSummaryLog("summary.EA.lhs.108.log"))
results <- rbind(results, readSummaryLog("summary.AgingEvol.lhs.36.log"))
results <- rbind(results, readSummaryLog("summary.AgingEvol.lhs.108.log"))

results <- rbind(results, readSummaryLog("summary.RS.rand.36.log"))
results <- rbind(results, readSummaryLog("summary.RS.rand.108.log"))

results$epochs <- as.factor(results$epochs)
results$init <- as.factor(results$init)

p <- ggplot(results, aes(x=algorithm, y=test_accuracy)) + geom_boxplot(aes(fill=init)) 
p <- p + theme_bw() + facet_wrap(~epochs, nrow=1) + theme(text=element_text(size=27))
p <- p + ylab("Test accuracy") + xlab("Algorithm")  + ylim(0.7, 0.948)
p


wilcox.test(
  results[which(results$algorithm=="GA" & results$epochs==36 & results$init=="rand"), c("test_accuracy")],
  results[which(results$algorithm=="GA" & results$epochs==36 & results$init=="centroids"), c("test_accuracy")])
wilcox.test(
  results[which(results$algorithm=="GA" & results$epochs==36 & results$init=="lhs"), c("test_accuracy")],
  results[which(results$algorithm=="GA" & results$epochs==36 & results$init=="centroids"), c("test_accuracy")])


wilcox.test(
  results[which(results$algorithm=="GA" & results$epochs==108 & results$init=="rand"), c("test_accuracy")],
  results[which(results$algorithm=="GA" & results$epochs==108 & results$init=="centroids"), c("test_accuracy")])
wilcox.test(
  results[which(results$algorithm=="GA" & results$epochs==108 & results$init=="lhs"), c("test_accuracy")],
  results[which(results$algorithm=="GA" & results$epochs==108 & results$init=="centroids"), c("test_accuracy")])

wilcox.test(
  results[which(results$algorithm=="EA" & results$epochs==36 & results$init=="rand"), c("test_accuracy")],
  results[which(results$algorithm=="EA" & results$epochs==36 & results$init=="centroids"), c("test_accuracy")])
wilcox.test(
  results[which(results$algorithm=="EA" & results$epochs==36 & results$init=="lhs"), c("test_accuracy")],
  results[which(results$algorithm=="EA" & results$epochs==36 & results$init=="centroids"), c("test_accuracy")])

wilcox.test(
  results[which(results$algorithm=="EA" & results$epochs==108 & results$init=="rand"), c("test_accuracy")],
  results[which(results$algorithm=="EA" & results$epochs==108 & results$init=="centroids"), c("test_accuracy")])
wilcox.test(
  results[which(results$algorithm=="EA" & results$epochs==108 & results$init=="lhs"), c("test_accuracy")],
  results[which(results$algorithm=="EA" & results$epochs==108 & results$init=="centroids"), c("test_accuracy")])


wilcox.test(
  results[which(results$algorithm=="AgingEvol" & results$epochs==36 & results$init=="rand"), c("test_accuracy")],
  results[which(results$algorithm=="AgingEvol" & results$epochs==36 & results$init=="centroids"), c("test_accuracy")])
wilcox.test(
  results[which(results$algorithm=="AgingEvol" & results$epochs==108 & results$init=="rand"), c("test_accuracy")],
  results[which(results$algorithm=="AgingEvol" & results$epochs==108 & results$init=="centroids"), c("test_accuracy")])
wilcox.test(
  results[which(results$algorithm=="AgingEvol" & results$epochs==108 & results$init=="lhs"), c("test_accuracy")],
  results[which(results$algorithm=="AgingEvol" & results$epochs==108 & results$init=="centroids"), c("test_accuracy")])






readGenLog <- function(filename) {
  alg <- strsplit(filename, "[.]")[[1]][2]
  init <- strsplit(filename, "[.]")[[1]][3]
  epochs <- strsplit(filename, "[.]")[[1]][4]
  raw_log <- read.csv(filename, sep="\t", header=FALSE)
  colnames(raw_log) <- c("ngen", "evals", "mean", "std", "min", "max")
  raw_log$algorithm <- alg
  raw_log$init <- init
  raw_log$epochs <- epochs
  raw_log$seed <- unlist(lapply(1:100, function(x){ rep(x, 153)}))
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


log <- rbind(log, readGenLog("log.GA.lhs.36.log"))
log <- rbind(log, readGenLog("log.GA.lhs.108.log"))
log <- rbind(log, readGenLog("log.EA.lhs.36.log"))
log <- rbind(log, readGenLog("log.EA.lhs.108.log"))

meanLog <- data.frame()
for(alg in c("GA", "EA")) {
  for(init in c("rand", "centroids", "lhs")) {
    for(epochs in c(36, 108)) {
      for(i in 0:152) {
        tmp <- log[which(log$ngen==i & log$algorithm==alg & log$init==init & log$epochs==epochs), c("mean", "max", "evals", "min")]
        meanLog <- rbind(meanLog, data.frame(algorithm=alg, init=init, epochs=epochs, ngen=i * 13, mean=mean(tmp$mean), std=sd(tmp$mean), max=mean(tmp$max), stdmax=sd(tmp$max),  
                                             min=mean(tmp$min)) )
        
      }
    }
  }
}

#meanLog$evals <- meanLog$ngen * 19 + 19
#p <- ggplot(meanLog, aes(x=evals, y=mean)) + geom_line(aes(color=init))
#p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2)
#p <- p + ylab("Mean population validation accuracy") + xlab("Function evaluations")

#p <- ggplot(meanLog, aes(x=evals, y=max)) + geom_line(aes(color=init))
#p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2)
#p <- p + ylab("Mean max population validation accuracy") + xlab("Function evaluations")
#p

#p <- ggplot(meanLog, aes(x=ngen, y=mean)) + geom_line(aes(color=init))#, lwd = 1.25)
#p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2) + theme(text=element_text(size=20))
#p <- p + ylab("Mean population validation accuracy") + xlab("Step")
#p <- p + geom_ribbon(aes(x=ngen, y=mean, ymin=(mean-std), ymax=(mean+std), fill=init), alpha=0.1)
#p


##p <- ggplot(meanLog, aes(x=ngen, y=mean)) + geom_line(aes(color=init))#, lwd = 1.25)
#p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2) + theme(text=element_text(size=20))
#p <- p + ylab("Population validation accuracy") + xlab("Step")
#p <- p + geom_ribbon(aes(x=ngen, y=mean, ymin=min, ymax=max, fill=init), alpha=0.1)
#p

#p <- ggplot(meanLog, aes(x=ngen, y=max)) + geom_line(aes(color=init)) #, lwd = 1.25)
#p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2) + theme(text=element_text(size=20))
#p <- p + ylab("Mean max population validation accuracy") + xlab("Generation")
#p <- p + geom_ribbon(aes(x=ngen, y=mean, ymin=(mean-std), ymax=(mean+std), fill=init), alpha=0.1)
#p

p <- ggplot(meanLog, aes(x=ngen, y=mean)) + geom_line(aes(color=init))#, lwd = 1.25)
p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2) + theme(text=element_text(size=20))
p <- p + ylab("Mean population validation accuracy") + xlab("Step")
p <- p + geom_ribbon(aes(x=ngen, y=mean, ymin=(mean-std), ymax=(mean+std), fill=init), alpha=0.1)
p


p <- ggplot(meanLog, aes(x=ngen, y=mean)) + geom_line(aes(color=init))#, lwd = 1.25)
p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2) + theme(text=element_text(size=20))
p <- p + ylab("Population validation accuracy") + xlab("Step")
p <- p + geom_ribbon(aes(x=ngen, y=mean, ymin=min, ymax=max, fill=init), alpha=0.1)
p

###########################
###########################
######## Aging Evol
###########################
###########################


#results <- data.frame()
#results <- rbind(results, readSummaryLog("summary.AgingEvol.rand.36.log"))
#results <- rbind(results, readSummaryLog("summary.AgingEvol.rand.108.log"))

#results <- rbind(results, readSummaryLog("summary.AgingEvol.centroids.36.log"))
#results <- rbind(results, readSummaryLog("summary.AgingEvol.centroids.108.log"))
#results$epochs <- as.factor(results$epochs)
#results$init <- as.factor(results$init)

#p <- ggplot(results, aes(x=algorithm, y=test_accuracy)) + geom_boxplot(aes(fill=init)) 
#p <- p + theme_bw() + facet_wrap(~epochs, nrow=1)
#p <- p + ylab("Test accuracy") + xlab("Algorithm")
#p


#wilcox.test(
#  results[which(results$algorithm=="AgingEvol" & results$epochs==36 & results$init=="rand"), c("test_accuracy")],
#  results[which(results$algorithm=="AgingEvol" & results$epochs==36 & results$init=="centroids"), c("test_accuracy")])
#wilcox.test(
#  results[which(results$algorithm=="AgingEvol" & results$epochs==108 & results$init=="rand"), c("test_accuracy")],
#  results[which(results$algorithm=="AgingEvol" & results$epochs==108 & results$init=="centroids"), c("test_accuracy")])






readGenLog <- function(filename) {
  alg <- strsplit(filename, "[.]")[[1]][2]
  init <- strsplit(filename, "[.]")[[1]][3]
  epochs <- strsplit(filename, "[.]")[[1]][4]
  raw_log <- read.csv(filename, sep="\t", header=FALSE)
  colnames(raw_log) <- c("ngen", "evals", "mean", "std", "min", "max")
  raw_log$algorithm <- alg
  raw_log$init <- init
  raw_log$epochs <- epochs
  raw_log$seed <- unlist(lapply(1:100, function(x){ rep(x, 2000)}))
  return(raw_log)
}

#log <- data.frame()
log <- rbind(log, readGenLog("log.AgingEvol.rand.36.log"))
log <- rbind(log, readGenLog("log.AgingEvol.rand.108.log"))

log <- rbind(log, readGenLog("log.AgingEvol.centroids.36.log"))
log <- rbind(log, readGenLog("log.AgingEvol.centroids.108.log"))

log <- rbind(log, readGenLog("log.AgingEvol.lhs.36.log"))
log <- rbind(log, readGenLog("log.AgingEvol.lhs.108.log"))


#meanLog <- data.frame()
#meanLog$evals <- meanLog$ngen
for(alg in c("AgingEvol")) {
  for(init in c("rand", "centroids", "lhs")) {
    for(epochs in c(36, 108)) {
      for(i in 0:2001) {
        tmp <- log[which(log$ngen==i & log$algorithm==alg & log$init==init & log$epochs==epochs), c("mean", "max", "min")]
        meanLog <- rbind(meanLog, data.frame(algorithm=alg, init=init, epochs=epochs, ngen=i, mean=mean(tmp$mean), std=sd(tmp$mean), max=mean(tmp$max), stdmax=sd(tmp$max),  
                         min=mean(tmp$min)) )
      }
    }
  }
}

#p <- ggplot(meanLog, aes(x=ngen, y=mean)) + geom_line(aes(color=init), lwd=1.15)
#p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2) + theme(text=element_text(size=20))
#p <- p + ylab("Mean population validation accuracy") + xlab("Generation") + ylim(0.82, 0.95) + theme(text=element_text(size=27))
#p <- p + geom_ribbon(aes(x=ngen, y=mean, ymin=(mean-std), ymax=(mean+std), fill=init), alpha=0.1)
#p

#p <- ggplot(meanLog, aes(x=ngen, y=max)) + geom_line(aes(color=init), lwd=1.15)
#p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2) + theme(text=element_text(size=20))
#p <- p + ylab("Mean max population validation accuracy") + xlab("Generation") + ylim(0.92, 0.95) + theme(text=element_text(size=27))
#p <- p + geom_ribbon(aes(x=ngen, y=mean, ymin=(mean-std), ymax=(mean+std), fill=init), alpha=0.1)
#p

p <- ggplot(meanLog, aes(x=ngen, y=mean)) + geom_line(aes(color=init))#, lwd = 1.25)
p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2) + theme(text=element_text(size=20))
p <- p + ylab("Mean population validation accuracy") + xlab("Step")
p <- p + geom_ribbon(aes(x=ngen, y=mean, ymin=(mean-std), ymax=(mean+std), fill=init), alpha=0.1) + ylim(0.65, 0.95)
p


p <- ggplot(meanLog, aes(x=ngen, y=mean)) + geom_line(aes(color=init), lwd = 1.0)
p <- p + theme_bw() + facet_wrap(~epochs + algorithm, nrow=2) + theme(text=element_text(size=20))
p <- p + ylab("Population validation accuracy") + xlab("Step")
p <- p + geom_ribbon(aes(x=ngen, y=mean, ymin=min, ymax=max, fill=init), alpha=0.1) + ylim(0.60, 0.95)
p




