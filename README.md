---
output:
  md_document:
    variant: markdown_github
---
[![Build Status](https://travis-ci.org/fvafrCU/document.svg?branch=master)](https://travis-ci.org/fvafrCU/document)
[![Coverage Status](https://codecov.io/github/fvafrCU/document/coverage.svg?branch=master)](https://codecov.io/github/fvafrCU/document?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/document)](https://cran.r-project.org/package=document)


<!-- README.md is generated from README.Rmd. Please edit that file -->



# document
Run  
[roxygen2](https://cran.r-project.org/package=roxygen2) on single code files rather than whole packages.

on single code files rather than whole packages.

## Introduction
Please read the vignette. Either [the version on github](http://htmlpreview.github.io/?https://github.com/fvafrCU/cleanr/blob/master/inst/doc/cleanr_Introduction.html)
or the one released on [cran](https://cran.r-project.org/package=cleanr).

Or, after installation, the help page:

```r
help("excerptr-package", package = "excerptr")
```

```
#> Excerpt Structuring Comments from Your Code File and Set a Table of
#> Contents
#> 
#> Description:
#> 
#>      This is just an R interface to the python package excerpts (<URL:
#>      https://pypi.python.org/pypi/excerpts>).
#> 
#> Details:
#> 
#>      You will probably only want to use 'excerptr', see there for a
#>      usage example.
#> 
#> Author(s):
#> 
#>      Andreas Dominik Cullmann, <adc-r@arcor.de>
```
## Installation
You can install cleanr from github with:

```r
if (! require("devtools")) install.packages("devtools")
devtools::install_github("fvafrCU/cleanr", quiet = TRUE)
```
