# Author: Maria Nattestad
# Email: mnattest@cshl.edu
# This script is part of Assemblytics, a program to detect and analyze structural variants from an assembly aligned to a reference genome using MUMmer. 



library(ggplot2)


args<-commandArgs(TRUE)
output_prefix <- args[1]


filename <- paste(output_prefix,".Assemblytics_structural_variants.bed",sep="")

bed <- read.csv(filename, sep="\t", quote='', header=TRUE)

names(bed)[1:11] <- c("chrom","start","stop","name","size","strand","type","ref.dist","query.dist","contig_position","method.found")

types.allowed <- c("Insertion","Deletion","Repeat_expansion","Repeat_contraction","Tandem_expansion","Tandem_contraction")



bed$type <- factor(bed$type, levels = types.allowed)



theme_set(theme_gray(base_size = 24))


color_palette_name <- "Set1"
binwidth <- 5


png(paste(output_prefix,".Assemblytics.size_distributions.png", sep=""),1000,1000)
ggplot(bed[bed$size>=50,],aes(x=size, fill=type)) + geom_bar(binwidth=binwidth*10) + scale_fill_brewer(palette=color_palette_name,drop=FALSE) + facet_grid(type ~ .,drop=FALSE) + labs(fill="Structural variant type",x="Variant size",y="Count",title="Structural variants > 50 bp") + theme(
    strip.text=element_blank(),strip.background=element_blank(),
    plot.title = element_text(vjust=3)
    )
dev.off()


png(paste(output_prefix,".Assemblytics.size_distributions_large_structural.png", sep=""),1000,1000)
ggplot(bed[bed$size>=500,],aes(x=size, fill=type)) + geom_bar(binwidth=binwidth*10) + scale_fill_brewer(palette=color_palette_name,drop=FALSE) + facet_grid(type ~ .,drop=FALSE) + labs(fill="Structural variant type",x="Variant size",y="Count",title="Structural variants > 500 bp") + theme(strip.text=element_blank(),strip.background=element_blank(),plot.title = element_text(vjust=3))
dev.off()



png(paste(output_prefix,".Assemblytics.size_distributions_zoom_structural.png", sep=""),1000,1000)
ggplot(bed[bed$size>=50,],aes(x=size, fill=type)) + geom_bar(binwidth=binwidth) + xlim(0,500) + scale_fill_brewer(palette=color_palette_name,drop=FALSE) + facet_grid(type ~ .,drop=FALSE) + labs(fill="Structural variant type",x="Variant size",y="Count",title="Structural variants > 50 bp") + theme(strip.text=element_blank(),strip.background=element_blank(),plot.title = element_text(vjust=3))
dev.off()



png(paste(output_prefix,".Assemblytics.size_distributions_zoom.png", sep=""),1000,1000)
ggplot(bed,aes(x=size, fill=type)) + geom_bar(binwidth=binwidth) + scale_fill_brewer(palette=color_palette_name,drop=FALSE) + xlim(0,500) + facet_grid(type ~ .,drop=FALSE) + labs(fill="Variant type",x="Variant size",y="Count",title="All variants > 5 bp") + theme(strip.text=element_blank(),strip.background=element_blank(),plot.title = element_text(vjust=3))
dev.off()


png(paste(output_prefix,".Assemblytics.size_distributions_all_variants_full_view.png", sep=""),1000,1000)
ggplot(bed,aes(x=size, fill=type)) + geom_bar(binwidth=binwidth) + scale_fill_brewer(palette=color_palette_name,drop=FALSE) + facet_grid(type ~ .,drop=FALSE) + labs(fill="Variant type",x="Variant size",y="Count",title="All variants > 5 bp") + theme(strip.text=element_blank(),strip.background=element_blank(),plot.title = element_text(vjust=3))
dev.off()

 
