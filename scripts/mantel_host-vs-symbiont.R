#!/usr/bin/env Rscript
## run from Rfiles/scripts !!!

mypaths<-c("/Users/amankows/Library/R/3.6/library", "/Library/Frameworks/R.framework/Versions/3.6/Resources/library")
.libPaths(mypaths)
.libPaths()
library("ape")
library("ggplot2")
library("vegan")
library("gridExtra")
library("plyr")
library("MASS")
library("gdata")
library("dplyr")
library("reshape2")
library("forcats")
library("ggdark")
library("patchwork")
library("phytools")
library("Hmisc")
library("optparse")
library("stringr")
library("spaa")
library("ade4")

option_list<-list(
  make_option("--symbiont", type="character", default=NULL),
  make_option("--host", type="character", default=NULL),
  make_option("--output", type="character", default=NULL))
opt_parser=OptionParser(option_list=option_list)
opt=parse_args(opt_parser)

df.sym<-read.csv(opt$symbiont, sep="\t", header=T)
df.host<-read.csv(opt$host, sep=",", header=T)
df.merge<-merge(df.sym, df.host, by="ID")

host.matrix<-as.dist(xtabs(df.merge[,7] ~ df.merge[,2] + df.merge[,3]))
sym.matrix<-as.dist(xtabs(df.merge[,4] ~ df.merge[,2] + df.merge[,3]))
sym.mantel<-mantel.rtest(host.matrix, sym.matrix, nrepet=9999)

mantel.obs<-sym.mantel$obs
mantel.sign<-sym.mantel$pvalue
mantel.out<-data.frame(mantel.obs, mantel.sign)
names(mantel.out)<-c("R", "p")

write.table(mantel.out, file=opt$output, row.names=F, quote=F, sep="\t")