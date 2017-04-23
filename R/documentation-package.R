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
#' And there is a second issue: where not using functions heavily, my code often
#' becomes lengthy. For I use it to load, plot and model data, most of which
#' is done once and using functions for everything is ... a bit over the top.
#' As it becomes lengthy, I comment on the code to structure it. And I use 
#' markdown style comments as a standard to allow for several levels of
#' `structuring depth'. 
#'
#' The package is intended for two different scenarios:
#' \enumerate{
#'     \item I have a single R code file with one or more annotated functions,
#'     classes, methods \ldots (which might well be part of a (yet to be 
#'     started) package), for which I want reader friendly documentation.
#'     \item I have a single R file that is rather part of a scientific project:
#'     It would have a file header, maybe followed by some annotated functions,
#'     and the 'bottom' part containing the analysis structured by markdown
#'     style comments.
#'     In this case I would like to extract the roxygen documentation and the
#'     mardowned structure of the analysis into a single documentation file.
#'     But I don't know how to install ghostscript from within R, so I end up
#'     with two files: one with the roxygen documentation, the other one with
#'     containing the markdown structure.
#' }
#'
#' For the second scenario I have examples included: run 
#' \code{demo(documentation)}. The first scenario is rather trivial, 
#' but you can utilize the examples for the second.
#'
#' I am fully aware of the fact that roxygen2 is meant to document packages, not
#' single code chunks (see \emph{Note}). 
#' So should you. Nevertheless I feel the temptation to use
#' roxygen2-style comments in code chunks that aren't part of any package. And
#' to convert them to pdf for better readability.
#' @note This package is basically a wrapper to 
#' \enumerate{
#'     \item roxygen2. It internally creates a temporary package from the code
#'      files provided (using
#'      \code{\link[utils:package.skeleton]{utils::package.skeleton}}) 
#'      which it then passes to roxygen2.
#'     \item parse_markdown_comments.py, a python program to extract markdown
#'      comments from source files and feed them to
#'      \href{http://www.pandoc.org}{pandoc}.
#' }
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 65f8e4dd3f37d88ae1f2fcf5c5e25520a5b75f2e $
#' @section Warning: 
#' This package is definitely a \strong{beta version}. 
#' Use at your own risk.
#' Check your files into your version control system first.
#' 
#' This package writes to disk, so \strong{NEVER} run it with superuser powers.
#' @name documentation-package
#' @aliases documentation-package 
#' @docType package
#' @keywords package
#' @examples
#' \dontrun{
#'     demo(documentation)
#' }
NULL
