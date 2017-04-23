#' document a single R code file.
#' 
#' extract roxygen2-style and markdown comments from a single R code 
#' file and convert them to various human-readable formats.
#'
#' R is a programming language that supports and checks documentation for
#' program libraries (called `packages'). The package roxygen2 provides a
#' tool for creating documentation from annotated source code - much like 
#' doxygen, Javadoc and docstrings/pydoc do.
#' 
#' And R is a free software environment for statistical computing and graphics,
#' used by people like me who start out hacking down code, eventually pouring
#' chunks of code into functions (and sometimes even ending up creating and 
#' documenting packages).
#' Along that workflow you can't use R's documentation system, let alone
#' roxygen2, unless you've come to forge your code into a package.
#' 
#' I am fully aware of the fact that roxygen2 is meant to document packages, not
#' single code chunks (see \emph{Note}). 
#' So should you. Nevertheless I feel the temptation to use
#' roxygen2-style comments in code chunks that aren't part of any package. And
#' to convert them to pdf for better readability.
#' @note This package is basically a wrapper to 
#' \enumerate{
#'     \item \pkg{roxygen2}. It internally creates a temporary package from the code
#'      files provided (using
#'      \code{\link[utils:package.skeleton]{utils::package.skeleton}}) 
#'      which it then passes to roxygen2.
#'     \item 'R CMD' commands run by \pkg{callr}.
#' }
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 65f8e4dd3f37d88ae1f2fcf5c5e25520a5b75f2e $
#' @section Warning: 
#' This package writes to disk, so \strong{NEVER} run it with superuser powers.
#' @name document-package
#' @aliases document-package 
#' @docType package
#' @keywords package
#' @examples
NULL
