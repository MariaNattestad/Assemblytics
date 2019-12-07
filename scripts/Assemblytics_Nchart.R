#!/usr/bin/env Rscript

# Author: Maria Nattestad
# github.com/marianattestad/assemblytics

library(ggplot2)
library(scales)


args<-commandArgs(TRUE)
prefix <- args[1]


filename_ref <- paste(prefix, ".coords.ref.genome", sep="")
filename_query <- paste(prefix, ".coords.query.genome", sep="")



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

ref.cumsum.0 <- rbind(data.frame(NG=c(0),contig.length=max(ref.cumsum$contig.length),contig.source="Reference"),ref.cumsum)

query.cumsum.0 <- rbind(data.frame(NG=c(0),contig.length=max(query.cumsum$contig.length),contig.source="Query"),query.cumsum)

with.zeros <- rbind(ref.cumsum.0,query.cumsum.0)




bp_format<-function(num) {
    if (num > 1000000000) {
        paste(formatC(num/1000000000,format="f",digits=3,big.mark=",",drop0trailing = TRUE)," Gbp",sep="")
    }
    else if (num > 1000000) {
        paste(formatC(num/1000000,format="f",digits=3,big.mark=",",drop0trailing = TRUE)," Mbp",sep="")
    }
    else {
        paste(formatC(num,format="f",big.mark=",",drop0trailing = TRUE), " bp", sep="")
    } 
}

theme_set(theme_bw(base_size = 12) + theme(panel.grid.minor = element_line(colour = NA)))
colors <- c("blue","limegreen")


for (to_png in c(TRUE,FALSE)) {
    
    if (to_png) {
        png(file=paste(prefix,".Assemblytics.Nchart.png",sep=""),width=1000,height=1000,res=200)
    } else {
        pdf(paste(prefix,".Assemblytics.Nchart.pdf",sep=""))
    }
    
    if (nrow(with.zeros) > 2) {
        print(
            ggplot(with.zeros, aes(x = NG, y = contig.length, color=contig.source)) + 
                xlim(0,100) +
                scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x), labels = trans_format("log10", math_format(10^.x)), limits=c(1,genome.length)) + 
                geom_path(size=1.5,alpha=0.5) + 
                geom_point(data=both.plot,size=2,alpha=0.5) + 
                labs(x = paste("NG(x)% where 100% = ",bp_format(genome.length), sep=""),y="Sequence length",colour="Assembly",title="Cumulative sequence length") +
                scale_color_manual(values=colors) +
                annotation_logticks(sides="lr")
              )
    } else {
        # To make bacterial genomes at least show a dot instead of an error because  
        # they only have 1 contig
        print(
            ggplot(both.plot, aes(x = NG, y = contig.length, color=contig.source)) + 
              xlim(0,100) +
              scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x), labels = trans_format("log10", math_format(10^.x)), limits=c(1,genome.length)) + 
#               geom_path(size=1.5,alpha=0.5) +
              geom_point(size=4,alpha=0.5) +
              labs(x = paste("NG(x)% where 100% = ",bp_format(genome.length), sep=""),y="Sequence length",colour="Assembly",title="Cumulative sequence length") +
              scale_color_manual(values=colors) +
              annotation_logticks(sides="lr")
        )
    }
    dev.off()
}




