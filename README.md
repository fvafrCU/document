[![Build Status](https://travis-ci.org/fvafrCU/document.svg?branch=master)](https://travis-ci.org/fvafrCU/document)
[![Coverage Status](https://codecov.io/github/fvafrCU/document/coverage.svg?branch=master)](https://codecov.io/github/fvafrCU/document?branch=master)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/document)](https://cran.r-project.org/package=document)
[![RStudio_downloads_monthly](https://cranlogs.r-pkg.org/badges/document)](https://cran.r-project.org/package=document)
[![RStudio_downloads_total](https://cranlogs.r-pkg.org/badges/grand-total/document)](https://cran.r-project.org/package=document)

<!-- README.md is generated from README.Rmd. Please edit that file -->



# document

## Introduction
Please read the [vignette](https://htmlpreview.github.io/?https://github.com/fvafrCU/document/blob/master/inst/doc/Introduction_to_document.html).

Or, after installation, the help page:

```r
help("document-package", package = "document")
```

```
# Document a Single R Code File
# 
# Description:
# 
#      Have you ever been tempted to create 'roxygen2'-style
#      documentation comments for one of your functions that was not part
#      of one of your packages (yet)? This is exactly what this package
#      is about: running 'roxygen2::roxygenize' on (chunks of) a single
#      code file.
#      This package enables you to
# 
#        1. create function documentation with 'roxygen2'
# 
#        2. detect code/documentation mismatches
# 
#        3. save the documentation to disk
# 
#        4. view the documentation in your interactive R session
# 
#      You will probably be looking for 'document' and 'man', the
#      remaining functions documented here are mainly for internal use.
# 
# Details:
# 
#      R is a programming language that supports and checks documentation
#      for program libraries (called `packages'). The package 'roxygen2'
#      provides a tool for creating documentation from annotated source
#      code - much like 'doxygen', 'javadoc' and 'docstrings/pydoc' do.
# 
#      And R is a free software environment for statistical computing and
#      graphics, used by people like me who start out hacking down code,
#      eventually pouring chunks of code into functions (and sometimes
#      even ending up creating and documenting packages). Along that work
#      flow you cannot use R's documentation system, let alone
#      'roxygen2', unless you have come to forge your code into a
#      package.
# 
#      I am fully aware of the fact that 'roxygen2' is meant to document
#      packages, not single code chunks. So should you. Nevertheless I
#      feel the temptation to use 'roxygen2'-style comments in code
#      chunks that are not part of any package. And to convert them to
#      pdf for better readability.
# 
# Warning:
# 
#      This package writes to disk, so *never* run as superuser.
# 
# Note:
# 
#      This package is basically a wrapper to
# 
#        1. 'roxygen2'. It internally creates a temporary package from
#           the code file provided (using 'utils::package.skeleton')
#           which it then passes to 'roxygen2::roxygenize'.
# 
#        2. 'R CMD' commands run by 'callr'.
# 
# See Also:
# 
#      'docstring' (<URL: https://cran.r-project.org/package=docstring>)
#      also creates temporary help pages as well but using a different
#      technical approach (allowing you to view them in the 'RStudio'
#      help pane). But it creates them from python style 'docstring'-like
#      comments it then parses into 'roxygen2'. And it does not write to
#      file so far.
```
## Installation
You can install document from github with:

```r
if (! require("devtools")) install.packages("devtools")
devtools::install_github("fvafrCU/document", quiet = TRUE)
```
