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

## Write down what versions of packages you used.
works_with_R("3.0.2", ggplot2="0.9.3.1", plyr="1.8", directlabels="2013.9.17")

## Read the mean and SD numbers from CSV.
CompareAUC <- read.csv("CompareAUC.csv")

## Look at the first few rows.
CompareAUC[1:20,]

## Look at the structure of an R object.
str(CompareAUC) # Factor means categorical variable, num means real number.

## The best is to show all the data points, if possible.
ggplot()+
  geom_point(aes(prop, auc, color=model), data=CompareAUC)+
  facet_grid(.~norm)

## We can use the mean and standard deviation to summarize these
## points.
auc.stats <- ddply(CompareAUC, .(model, norm, prop), summarize,
                   mean=mean(auc), sd=sd(auc))
auc.stats[1:20,]
str(auc.stats)

## Show points AND mean lines AND error bands, to show that most of
## the points are contained within the bands.
ggplot()+
  geom_point(aes(prop, auc, color=model), data=CompareAUC)+
  facet_grid(.~norm)+
  geom_ribbon(aes(prop, ymin=mean-sd, ymax=mean+sd, group=model, fill=model),
              data=auc.stats, alpha=1/3)+
  geom_line(aes(prop, mean, group=model, color=model), data=auc.stats)

## Most of the time we show just lines AND error bands.
ErrorBandsLegend <- ggplot()+
  facet_grid(.~norm, labeller=label_both)+
  geom_ribbon(aes(prop, ymin=mean-sd, ymax=mean+sd, group=model, fill=model),
              data=auc.stats, alpha=1/3)+
  geom_line(aes(prop, mean, group=model, color=model), data=auc.stats)
print(ErrorBandsLegend)

## Draw direct labels instead of a legend, and label the axes, for
## easy reading.
ErrorBandsLabeled <- direct.label(ErrorBandsLegend)+
  xlim(0.1, 1.1)+
  theme(legend.position="null")+
  ylab("Area under the ROC curve\nmean + SD over 4 test sets")+
  xlab("Proportion of equality pairs in train and test data")
print(ErrorBandsLabeled)

## Export to PDF.
pdf("figure-CompareAUC.pdf", h=3)
print(ErrorBandsLabeled)
dev.off()

png("figure-CompareAUC-low-res.png", h=300)
print(ErrorBandsLabeled)
dev.off()
