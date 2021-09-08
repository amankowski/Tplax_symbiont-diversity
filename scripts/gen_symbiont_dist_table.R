#!/usr/bin/env Rscript
## run from Rfiles/scripts !!!

mypaths<-c("/Users/amankows/Library/R/3.6/library", "/Library/Frameworks/R.framework/Versions/3.6/Resources/library")
.libPaths(mypaths)
.libPaths()
library("ape")
library("plyr")
library("dplyr")
library("reshape2")
library("forcats")
library("optparse")
library("stringr")

option_list<-list(
  make_option("--symbiont", type="character", default=NULL),
  make_option("--output", type="character", default=NULL))
opt_parser=OptionParser(option_list=option_list)
opt=parse_args(opt_parser)

symbiont=paste(opt$symbiont, "$", sep="")

symbiont.tree.individuals<-read.tree("./data/symbiont-tree.for-dist.newick")
symbiont.labels<-grep(symbiont, symbiont.tree.individuals$tip.label, value=T)
symbiont.tree<-keep.tip(symbiont.tree.individuals, symbiont.labels)
symbiont.tree$tip.label<-gsub(paste('.', symbiont, sep=""), '', symbiont.tree$tip.label)
symbiont.nt.dist<-reshape2::melt(cophenetic(symbiont.tree))
symbiont=opt$symbiont
symbiont.nt.dist$symbiont<-symbiont
write.table(symbiont.nt.dist, file=opt$output, row.names=F, col.names=F, sep="\t", quote=F)
