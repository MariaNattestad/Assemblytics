library(ggplot2)
library(plyr)

args<-commandArgs(TRUE)
output_prefix <- args[1]
abs_min_var <- as.numeric(args[2])
abs_max_var <- as.numeric(args[3])

# output_prefix <- "~/tmp/Escherichia_coli_MHAP_assembly"

filename <- paste(output_prefix,".Assemblytics_structural_variants.bed",sep="")

# print(filename)
bed <- read.csv(filename, sep="\t", quote='', header=TRUE)

names(bed)[1:11] <- c("chrom","start","stop","name","size","strand","type","ref.dist","query.dist","contig_position","method.found")
# head(bed)

# summary(bed$type)

bed$type <- revalue(bed$type, c("Repeat_expansion"="Repeat expansion", "Repeat_contraction"="Repeat contraction", "Tandem_expansion"="Tandem expansion", "Tandem_contraction"="Tandem contraction"))

types.allowed <- c("Insertion","Deletion","Repeat expansion","Repeat contraction","Tandem expansion","Tandem contraction")
bed$type <- factor(bed$type, levels = types.allowed)

# summary(bed$type)

theme_set(theme_bw(base_size = 12))


# library(RColorBrewer)
# display.brewer.all()
color_palette_name <- "Set1"

# Nature-style formatting for publication using commas (e.g.: 7,654,321)
comma_format<-function(num) {
    formatC(num,format="f",big.mark=",",drop0trailing = TRUE)
}

###############     Flexible plotting function     ###############
plot_size_distribution <- function(min_var,max_var,indels_only) {     
    types_to_plot = types.allowed
    if (indels_only) {
        types_to_plot <- c("Insertion","Deletion")
    }
    filtered_bed <- bed[bed$size>=min_var & 
                    bed$size<=max_var & 
                    bed$type %in% types_to_plot,]
    filtered_bed$type <- factor(filtered_bed$type,levels=types_to_plot)
    binwidth <- max_var/100
    if (binwidth < 1) {
        binwidth <- 1
    }
    
    if (nrow(filtered_bed)>0) {
        print(ggplot(filtered_bed,aes(x=size, fill=type)) + 
          geom_bar(binwidth=binwidth) + 
          
          scale_fill_brewer(palette=color_palette_name,drop=FALSE) + 
          facet_grid(type ~ .,drop=FALSE) + 
          labs(fill="Variant type",x="Variant size",y="Count",title=paste("Variants",comma_format(min_var),"to", comma_format(max_var),"bp")) + 
                  scale_x_continuous(labels=comma_format,expand=c(0,0),limits=c(min_var,max_var)) +
                  scale_y_continuous(labels=comma_format,expand=c(0,0)) +
          theme(
              strip.text=element_blank(),strip.background=element_blank(),
              plot.title = element_text(vjust=3),
              axis.text=element_text(size=8),
              panel.grid.minor = element_line(colour = NA),
              panel.grid.major = element_line(colour = NA)
          )
        )
    } else {        
        print("No variants in plot:")
        print(paste("min_var=",min_var))
        print(paste("max_var=",max_var))
    }
}

#######   Run plotting with various size ranges and with either all variants or only indels ######
var_size_cutoffs <- c(abs_min_var,10,50,500,abs_max_var)
var_size_cutoffs <- var_size_cutoffs[var_size_cutoffs>=abs_min_var & var_size_cutoffs<=abs_max_var]

for (to_png in c(TRUE,FALSE)) {
    for (indels_only in c(TRUE,FALSE)) {
        var_type_filename <- "all_variants"
        if (indels_only) {
            var_type_filename <- "indels"
        }
        for (i in seq(1,length(var_size_cutoffs)-1)) {
            min_var <- var_size_cutoffs[i]
            max_var <- var_size_cutoffs[i+1]
            if (to_png) {
                png(paste(output_prefix,".Assemblytics.size_distributions.", var_type_filename, ".", min_var, "-",max_var, ".png", sep=""),1000,1000,res=200)
            } else {
                pdf(paste(output_prefix,".Assemblytics.size_distributions.", var_type_filename, ".", min_var, "-",max_var, ".pdf", sep=""))
            }
            plot_size_distribution(min_var=min_var,max_var=max_var,indels_only=indels_only)
            dev.off()
        }
    }
}


