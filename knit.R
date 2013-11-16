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

works_with_R("3.0.2", knitr="1.4.1")

tmp <- '
```{r, "NAME", tidy=FALSE}
CODE
```
'

figs <- Sys.glob("figure-*.R")
for(fig in figs){
  code <- readLines(fig)
  filled <- sub("CODE", paste(code, collapse="\n"), sub("NAME", fig, tmp),
                fixed=TRUE)
  Rmd <- sub("R$", "Rmd", fig)
  writeLines(filled, Rmd)
  knit2html(Rmd)
}
