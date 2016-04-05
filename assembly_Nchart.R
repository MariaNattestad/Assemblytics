# Author: Maria Nattestad
# Email: mnattest@cshl.edu
# This script is part of Assemblytics, a program to detect and analyze structural variants from an assembly aligned to a reference genome using MUMmer. 


library(ggplot2)
library(scales)


args<-commandArgs(TRUE)
prefix <- args[1]


filename_ref <- paste(prefix, ".coords.ref.genome", sep="")
filename_query <- paste(prefix, ".coords.query.genome", sep="")


plot.output.filename <- paste(prefix,".Assemblytics.Nchart.png",sep="")


ref.data <- read.csv(filename_ref, sep="\t", quote='',header=FALSE)


query.data <- read.csv(filename_query, sep="\t", quote='',header=FALSE)
names(ref.data) <- c("name","length")
names(query.data) <- c("name","length")


ref.data$length <- as.numeric(ref.data$length)
query.data$length <- as.numeric(query.data$length)

genome.length <- max(sum(ref.data$length),sum(query.data$length))


ref.cumsum <- data.frame(NG=cumsum(ref.data$length/genome.length*100),contig.length=ref.data$length,contig.source="Reference")


query.cumsum <- data.frame(NG=cumsum(query.data$length/genome.length*100),contig.length=query.data$length,contig.source="Query")

both.plot <- rbind(ref.cumsum,query.cumsum)



  
png(file=plot.output.filename,width=1000,height=1000)

theme_set(theme_gray(base_size = 24))

if (nrow(both.plot) > 2) {
    ggplot(both.plot, aes(x = NG, y = contig.length,color=contig.source)) + xlim(0,100) + scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x), labels = trans_format("log10", math_format(10^.x))) + geom_path(size=2) + labs(x = paste("NG(x)% where 100% = ",genome.length," bp", sep=""),y="Sequence length",colour="Assembly") + annotation_logticks(sides="lr")
    
} else {
    ggplot(both.plot, aes(x = NG, y = contig.length,color=contig.source)) + xlim(0,100) +  geom_point(size=5) + ylim(0,genome.length) + labs(x = paste("NG(x)% where 100% = ",genome.length," bp", sep=""),y="Sequence length",colour="Assembly")
}

dev.off()





