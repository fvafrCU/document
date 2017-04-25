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
Run  [roxygen2](https://cran.r-project.org/package=roxygen2) on single code files rather than whole packages.


## Introduction
Please read the [vignette](http://htmlpreview.github.io/?https://github.com/fvafrCU/document/blob/master/inst/doc/document_Introduction.html).

Or, after installation, the help page:

```r
help("document-package", package = "document")
```

```
#> document a single R code file.
#> 
#> Description:
#> 
#>      extract roxygen2-style and markdown comments from a single R code
#>      file and convert them to various human-readable formats.
#> 
#> Details:
#> 
#>      R is a programming language that supports and checks documentation
#>      for program libraries (called `packages'). The package roxygen2
#>      provides a tool for creating documentation from annotated source
#>      code - much like doxygen, javadoc and docstrings/pydoc do.
#> 
#>      And R is a free software environment for statistical computing and
#>      graphics, used by people like me who start out hacking down code,
#>      eventually pouring chunks of code into functions (and sometimes
#>      even ending up creating and documenting packages). Along that work
#>      flow you cannot use R's documentation system, let alone roxygen2,
#>      unless you have come to forge your code into a package.
#> 
#>      I am fully aware of the fact that roxygen2 is meant to document
#>      packages, not single code chunks (see _Note_).  So should you.
#>      Nevertheless I feel the temptation to use roxygen2-style comments
#>      in code chunks that are not part of any package. And to convert
#>      them to pdf for better readability.
#> 
#> Warning:
#> 
#>      This package writes to disk, so *NEVER* run it with superuser
#>      powers.
#> 
#> Note:
#> 
#>      This package is basically a wrapper to
#> 
#>        1. 'roxygen2'. It internally creates a temporary package from
#>           the code files provided (using 'utils::package.skeleton')
#>           which it then passes to roxygen2.
#> 
#>        2. 'R CMD' commands run by 'callr'.
#> 
#> Author(s):
#> 
#>      Andreas Dominik Cullmann, <adc-r@arcor.de>
```
## Installation
You can install document from github with:

```r
if (! require("devtools")) install.packages("devtools")
devtools::install_github("fvafrCU/document", quiet = TRUE)
```
