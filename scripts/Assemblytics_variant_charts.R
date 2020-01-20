#!/usr/bin/env Rscript

# Author: Maria Nattestad
# github.com/marianattestad/assemblytics

library(ggplot2)
library(plyr)
library(RColorBrewer)

args<-commandArgs(TRUE)
output_prefix <- args[1]
abs_min_var <- as.numeric(args[2])
abs_max_var <- as.numeric(args[3])


filename <- paste(output_prefix,".Assemblytics_structural_variants.bed",sep="")

bed <- read.csv(filename, sep="\t", quote='', header=TRUE)

names(bed)[1:11] <- c("chrom","start","stop","name","size","strand","type","ref.dist","query.dist","contig_position","method.found")

bed$type <- revalue(bed$type, c("Repeat_expansion"="Repeat expansion", "Repeat_contraction"="Repeat contraction", "Tandem_expansion"="Tandem expansion", "Tandem_contraction"="Tandem contraction"))

types.allowed <- c("Insertion","Deletion","Repeat expansion","Repeat contraction","Tandem expansion","Tandem contraction")
bed$type <- factor(bed$type, levels = types.allowed)

theme_set(theme_bw(base_size = 12))

color_palette_name <- "Set1"
big_palette<-brewer.pal(9,"Set1")[c(1,2,3,4,5,7)]

# Nature-style formatting for publication using commas (e.g.: 7,654,321)
comma_format<-function(num) {
    formatC(abs(num),format="f",big.mark=",",drop0trailing = TRUE)
}

# Prep data for log-scaled plot
alt <- bed

alt[alt$type=="Deletion",]$size <- -1*alt[alt$type=="Deletion",]$size
alt[alt$type=="Repeat contraction",]$size <- -1*alt[alt$type=="Repeat contraction",]$size
alt[alt$type=="Tandem contraction",]$size <- -1*alt[alt$type=="Tandem contraction",]$size

alt$Type <- "None"
if (nrow(alt[alt$type %in% c("Insertion","Deletion"),]) > 0) {
    alt[alt$type %in% c("Insertion","Deletion"),]$Type <- "Indel"    
}
if (nrow(alt[alt$type %in% c("Tandem expansion","Tandem contraction"),]) > 0) {
    alt[alt$type %in% c("Tandem expansion","Tandem contraction"),]$Type <- "Tandem"    
}
if (nrow(alt[alt$type %in% c("Repeat expansion","Repeat contraction"),]) > 0) {
    alt[alt$type %in% c("Repeat expansion","Repeat contraction"),]$Type <- "Repeat"    
}


# Create plots for various size ranges 
var_size_cutoffs <- c(abs_min_var,10,50,500,abs_max_var)
var_size_cutoffs <- var_size_cutoffs[var_size_cutoffs>=abs_min_var & var_size_cutoffs<=abs_max_var]

for (to_png in c(TRUE,FALSE)) {
    var_type_filename <- "all_variants"
    for (i in seq(1,length(var_size_cutoffs)-1)) {
        min_var <- var_size_cutoffs[i]
        max_var <- var_size_cutoffs[i+1]
        if (min_var < abs_max_var && max_var > abs_min_var)
        {
            types_to_plot = types.allowed
            filtered_bed <- bed[bed$size>=min_var & 
                            bed$size<=max_var & 
                            bed$type %in% types_to_plot,]
            filtered_bed$type <- factor(filtered_bed$type,levels=types_to_plot)
            binwidth <- max_var/100
            if (binwidth < 1) {
                binwidth <- 1
            }
            
            if (nrow(filtered_bed)>0) {
                if (to_png) {
                    png(paste(output_prefix,".Assemblytics.size_distributions.", var_type_filename, ".", min_var, "-",max_var, ".png", sep=""),1000,1000,res=200)
                } else {
                    pdf(paste(output_prefix,".Assemblytics.size_distributions.", var_type_filename, ".", min_var, "-",max_var, ".pdf", sep=""))
                }

                print(ggplot(filtered_bed,aes(x=size, fill=type)) + 
                    geom_histogram(binwidth=binwidth) + 
                    scale_fill_manual(values=big_palette,drop=FALSE) + 
                    facet_grid(type ~ .,drop=FALSE) + 
                    labs(fill="Variant type",x="Variant size",y="Count",title=paste("Variants",comma_format(min_var),"to", comma_format(max_var),"bp")) + 
                            scale_x_continuous(labels=comma_format,expand=c(0,0), limits=c(min_var-1,max_var)) + 
                            scale_y_continuous(labels=comma_format,expand=c(0,0)) +
                    theme(
                        strip.text=element_blank(),strip.background=element_blank(),
                        plot.title = element_text(vjust=3),
                        axis.text=element_text(size=8),
                        panel.grid.minor = element_line(colour = NA),
                        panel.grid.major = element_line(colour = NA)
                    )
                )
                
                dev.off()
            } else {        
                print("No variants in plot:")
                print(paste("min_var=",min_var))
                print(paste("max_var=",max_var))
            }
            
        }
        
    }  
    
    
    # Save log-scaled plot to PNG
    if (to_png) {
        png(paste(output_prefix,".Assemblytics.size_distributions.", var_type_filename, ".log_all_sizes.png", sep=""),width=2000,height=1000,res=200)
    } else {
        pdf(paste(output_prefix,".Assemblytics.size_distributions.", var_type_filename, ".log_all_sizes.pdf", sep=""))
    }
    
    print(ggplot(alt,aes(x=size, fill=type,y=..count..+1)) + 
        geom_histogram(binwidth=abs_max_var/100, position="identity",alpha=0.7) + 
        scale_fill_manual(values=big_palette,drop=FALSE) + 
        facet_grid(Type ~ .,drop=FALSE) + 
        labs(fill="Variant type",x="Variant size",y="Log(count + 1)",title=paste("Variants",comma_format(abs_min_var),"to", comma_format(abs_max_var),"bp")) + 
        scale_x_continuous(labels=comma_format,expand=c(0,0),limits=c(-1*abs_max_var,abs_max_var)) + 
        scale_y_log10(labels=comma_format,expand=c(0,0)) +
        annotation_logticks(sides="l") +
        theme(
            strip.text=element_blank(),strip.background=element_blank(),
            plot.title = element_text(vjust=3),
            axis.text=element_text(size=8),
            panel.grid.minor = element_line(colour = NA),
            panel.grid.major = element_line(colour = NA)
        )
    )
    dev.off()
}
