library(ggplot2)


args<-commandArgs(TRUE)
prefix <- args[1]



for (filtered in c("Assemblytics filtered","Unfiltered")) {
    filename <- paste(prefix,".coords.flipped",sep="")
    plot.output.filename <- paste(prefix,".Assemblytics.Dotplot_filtered.png",sep="")
    plot.title <- "Dot plot of Assemblytics filtered alignments"


    if (filtered == "Unfiltered") {
        filename <- paste(prefix,".unfiltered.coords.flipped",sep="")
        plot.output.filename <- paste(prefix,".Assemblytics.Dotplot_unfiltered.png",sep="")
        plot.title <- "Dot plot of unfiltered alignments"
    }

    print(filename)
    print(plot.output.filename)
    print(plot.title)


    ref.pos <- function(chrom,pos,chr.lengths) {
        
        chrom.index <- which(names(chr.lengths)==chrom)-1
        offset.based.on.previous.chromosomes <- 0
        if (chrom.index != 0) {
            offset.based.on.previous.chromosomes <- sum(as.numeric(chr.lengths[c(1:chrom.index)])) 
        }
        
        loc <- offset.based.on.previous.chromosomes + pos   
        loc
    }


    coords <- read.csv(filename,sep="\t",header=FALSE)

    names(coords) <- c("ref.start", "ref.stop","query.start","query.stop","ref.alignment.length","query.alignment.length","percent.identity","ref.length","query.length","ref.fraction.covered","query.fraction.covered","ref","query")


    coords$ref <- as.character(coords$ref)
    coords$query <- as.character(coords$query)



    ordered_common_chromosome_names <- c(seq(1,100),paste("chr",seq(1,100),sep=""),paste("Chr",seq(1,100),sep=""),c("X","Y","M","MT","Chr0","chr0","0"))

    all_chromosomes_some_ordered <- c(intersect(ordered_common_chromosome_names,unique(coords$ref)),setdiff(unique(coords$ref),ordered_common_chromosome_names))



    coords$ref <- factor(coords$ref,levels=all_chromosomes_some_ordered)


    chromosomes <- levels(coords$ref)

    chr.lengths <- sapply(chromosomes,function(chr){max(coords[coords$ref==chr,"ref.length"])})
    names(chr.lengths) <- chromosomes

    coords <- cbind(coords, alignment.length=abs(coords$query.start-coords$query.stop))


    coords <- cbind(coords, ref.loc.start=mapply(FUN=ref.pos,coords$ref,coords$ref.start,MoreArgs=list(chr.lengths)),
                    ref.loc.stop=mapply(FUN=ref.pos,coords$ref,coords$ref.stop,MoreArgs=list(chr.lengths)))

    # pick longest alignment. then pick the ref.loc.start of that
    query.group <- split(coords,factor(coords$query))

    ref.loc.of.longest.alignment.by.query <- unlist(sapply(query.group, function(coords.for.each.query) {coords.for.each.query$ref.loc.start[coords.for.each.query$alignment.length==max(coords.for.each.query$alignment.length)][1]}),recursive=FALSE)


    # decide optimal-ish ordering of the queries
    ordered.query.names <- names(ref.loc.of.longest.alignment.by.query)[order(ref.loc.of.longest.alignment.by.query)]

    # construct a query.lengths list
    query.lengths <- sapply(ordered.query.names,function(each.query){
        max(coords[coords$query==each.query,"query.length"])
    })

    # use the query.lengths to give offset positions to each query, adding a query.loc.start column and a query.loc.stop column to each entry in filtered.coords

    coords$query.loc.start <- mapply(FUN=ref.pos,coords$query,coords$query.start,MoreArgs=list(query.lengths))
    coords$query.loc.stop <- mapply(FUN=ref.pos,coords$query,coords$query.stop,MoreArgs=list(query.lengths))


    # Hide labels for chromosomes accounting for less than 2% of the reference
    chr.labels <- names(chr.lengths)
    chr.labels[chr.lengths < 0.02*sum(as.numeric(chr.lengths))] <- ""

    query.labels <- names(query.lengths)
    query.labels[query.lengths < 0.02*sum(as.numeric(query.lengths))] <- ""


    png(file=plot.output.filename,width=1000,height=1000)


    theme_set(theme_bw(base_size = 24))
    # 1 line segment for each alignment, linking start and stop
    # some kind of gridline on plot to show where contigs start and end
    print(ggplot(coords, aes(x=ref.loc.start,xend=ref.loc.stop,y=query.loc.start,yend=query.loc.stop)) + geom_segment(lineend="butt",size=1.5) + labs(x="Reference",y="Query",title=plot.title) + scale_y_continuous(breaks = cumsum(as.numeric(query.lengths)),labels=query.labels,expand=c(0,0), limits = c(0,sum(as.numeric(query.lengths)))) + scale_x_continuous(breaks = cumsum(as.numeric(chr.lengths)),labels=chr.labels,expand=c(0,0),limits=c(0,sum(as.numeric(chr.lengths)))) + theme(
        axis.ticks.y=element_line(size=0),
        axis.text.x = element_text(angle = 90, hjust = 1,vjust=-0.5),
        axis.text.y = element_text(size=12,vjust=1.1),
        plot.title = element_text(vjust=3),
        panel.grid.major.x = element_line(colour = "black",size=0.1), 
        panel.grid.major.y = element_line(colour = "black",size=0.1), 
        panel.grid.minor = element_line(NA)
    ))

    dev.off()

}




