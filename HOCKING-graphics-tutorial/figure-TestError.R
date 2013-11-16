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
works_with_R("3.0.2",ggplot2="0.9.3.1")

## Read error curves into an R data.frame.
TestError <- read.csv("TestError.csv")
curves <- subset(TestError,statistic=="errors")

## Show the first few rows of the data to plot.
curves[1:10,]

## Describe the desired plot using the ggplot2 package.
library(ggplot2)
with.legend <- ggplot(curves,aes(training.set.profiles,mean))+
  geom_ribbon(aes(ymin=mean-sd,ymax=mean+sd,group=algorithm,fill=algorithm),
              alpha=1/4)+ # degree of transparency \in [0,1]
  geom_line(aes(group=algorithm,colour=algorithm),
            size=1.5)+ # line thickness \in \RR
  scale_x_continuous("Annotated profiles in global model training set",
                     breaks=c(1,5,10,15,20,25,30))+
  scale_y_continuous(paste("Percent of incorrectly predicted annotations",
                           "on test set"),
                     breaks=seq(0,20,by=2))+
  theme_bw()
print(with.legend)

## Get rid of the legend.
no.legend <- with.legend+
  guides(colour="none",fill="none")

## The directlabels package provides automatic label placement, for
## everyday graphics.
library(directlabels)
auto.labels <- direct.label(no.legend)
print(auto.labels)

## Manually define the range of the axes, so there is more room for
## the labels.
resized <- auto.labels+
  coord_cartesian(xlim=c(1,35),ylim=c(0,20))
print(resized)

## For publication-quality graphics, it is useful to manually specify
## labels by typing their desired positions.
algo.labels <- data.frame(training.set.profiles=29.5,
                          mean=c(17,10,7,1),
  algorithm=c("glad.lambdabreak","dnacopy.sd",
    "flsa.norm","cghseg.k"))
manual.labels <- no.legend+
  coord_cartesian(xlim=c(1,30),ylim=c(0,20))+
  geom_text(aes(colour=algorithm,label=algorithm),
            data=algo.labels,
            hjust=1)
print(manual.labels)

png("figure-TestError.png",w=1200,h=1200,res=240,type="cairo")
print(manual.labels)
dev.off()

png("figure-TestError-thumb.png",type="cairo")
print(manual.labels)
dev.off()
