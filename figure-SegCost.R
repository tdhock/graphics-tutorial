## Set some global options:
options(repos=c( # where to find packages:
          "http://r-forge.r-project.org",
          "http://cran.ism.ac.jp",
          "http://mirror.ibcp.fr/pub/CRAN/",
          "http://cran.r-project.org"))

### Install R packages, and warn if versions do not match.
works_with_R <- function(Rvers,...){
  pkg_need_have <- function(pkg,need,have){
    if(need != have){
      warning("works with ",pkg," version ",need,", have ",have)
    }
  }
  pkg_need_have("R",Rvers,getRversion())
  pkg.vers <- list(...)
  for(pkg in names(pkg.vers)){
    if(!require(pkg,character.only=TRUE)){
      install.packages(pkg)
    }
    pkg_need_have(pkg,pkg.vers[[pkg]],packageVersion(pkg))
    require(pkg,character.only=TRUE)
  }
}

## Indicate what versions of packages were used.
works_with_R("3.0.2",ggplot2="0.9.3.1",directlabels="2013.9.17",tikzDevice="0.6.3")

## Read a CSV data table into R as a data.frame, which is like a
## matrix but whose columns can be different data types.
SegCost <- read.csv("SegCost.csv")

## Display the first 25 rows.
SegCost[1:25,]

## Text data such as the error column are treated by R as a
## categorical variable or "factor" with discrete "levels." For
## example, the error column is a factor with 4 levels: E, FN, FP, I.
SegCost[1:25,"error"]

## Re-order the factor levels, which controls the order of display on
## the plot.
SegCost[,"error"] <- factor(SegCost[,"error"],c("FP","FN","E","I"))
SegCost[1:25,"error"]

## Define the colors, line sizes, and line types to use for plotting.
fp.fn.colors <- c(FP="skyblue",FN="#E41A1C",I="black",E="black")
fp.fn.sizes <- c(FP=2.5,FN=2.5,I=1,E=1)
fp.fn.linetypes <- c(FP="solid",FN="solid",I="dashed",E="solid")

## The ggplot2 package makes it easy to plot multipanel, multicolor
## figures.
err.df <- subset(SegCost,type!="Signal")
kplot <- ggplot(err.df,aes(segments,cost))+
  geom_line(aes(colour=error,size=error,linetype=error))+
  scale_linetype_manual(values=fp.fn.linetypes)+
  scale_colour_manual(values=fp.fn.colors)+
  scale_size_manual(values=fp.fn.sizes)+
  ## custom x and y axis labels:
  scale_x_continuous("number of segments $k$ in estimated model",
    limits=c(0,20),breaks=c(1,7,20),minor_breaks=NULL)+
  ylab("$e_i(k) = $ cost of model $k$ for signal $i$")+
  ## The next line means: make a matrix of plots, with one value of
  ## the type variable on each row, and one value of the
  ## bases.per.probe variable on each column.
  facet_grid(type~bases.per.probe,labeller=function(var,val){
    if(var=="bases.per.probe"){
      sprintf("signal $i=%s$",val)
    }else{
      as.character(val)
    }
  })+
  theme_grey()
print(kplot)

## You can use theme_bw with no space between panels to save space.
bwplot <- kplot+
  theme_bw()+theme(panel.margin=grid::unit(0,"lines"))
print(bwplot)

## You can easily add direct labels, which are often easier to read
## than a legend. "last.qp" is the label placement method, which means
## to put the labels after the last points (at the end of the lines).
dlplot <- direct.label(bwplot,"last.qp")+
  guides(size="none",linetype="none")+
  coord_cartesian(xlim=c(1,22))
print(dlplot)

## The tikzDevice package provides the tikz() function which starts a
## graphics device that outputs native LaTeX/tikz code. Tell R how
## your LaTeX document starts, so text sizes can be calculated.
options(tikzDocumentDeclaration="\\documentclass[11pt]{article}",
        ## Directory where to save LaTeX size calculations.
        tikzMetricsDictionary="tikzMetrics")

tikz("figure-SegCost.tex",w=5,h=4) # inches.
print(dlplot)
dev.off()

png("figure-SegCost.png") 
print(dlplot)
dev.off()
