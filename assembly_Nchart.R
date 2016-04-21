# Author: Maria Nattestad
# Email: mnattest@cshl.edu
# This script is part of Assemblytics, a program to detect and analyze structural variants from an assembly aligned to a reference genome using MUMmer. 


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
    
    if (nrow(both.plot) > 2) {
        print(
            ggplot(both.plot, aes(x = NG, y = contig.length, color=contig.source)) + 
                xlim(0,100) +
                scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x), labels = trans_format("log10", math_format(10^.x)), limits=c(1,genome.length)) + 
#                 scale_x_continuous(expand=c(0,0),limits=c(0,100)) +
                geom_path(size=1.5,alpha=0.5) +
                geom_point(size=2,alpha=0.5) +
                labs(x = paste("NG(x)% where 100% = ",bp_format(genome.length), sep=""),y="Sequence length",colour="Assembly",title="Cumulative sequence length") +
                scale_color_manual(values=colors) +
                annotation_logticks(sides="lr")
              )
    } else {
        # To make bacterial genomes at least show a dot instead of an error because  
        # they only have 1 contig
        print(ggplot(both.plot, aes(x = NG, y = contig.length,color=contig.source)) + xlim(0,100) +  geom_point(size=5) + ylim(0,genome.length) + labs(x = paste("NG(x)% where 100% = ",genome.length," bp", sep=""),y="Sequence length",colour="Assembly"))
    }
    dev.off()
}




