#' Document a Single R Code File
#'
#' Have you ever been tempted to create roxygen2-style documentation comments
#' for one of your functions that was not part of one of your packages (yet)?
#' This is exactly what this package is about: running roxygen2 on (chunks of)
#' a single code file.\cr
#' You will probably look for \code{\link{document}} and \code{\link{man}}, the
#' remaining functions documented here are mainly for internal use.
#'
#' R is a programming language that supports and checks documentation for
#' program libraries (called `packages'). The package roxygen2 provides a
#' tool for creating documentation from annotated source code - much like
#' doxygen, javadoc and docstrings/pydoc do.
#'
#' And R is a free software environment for statistical computing and graphics,
#' used by people like me who start out hacking down code, eventually pouring
#' chunks of code into functions (and sometimes even ending up creating and
#' documenting packages).
#' Along that work flow you cannot use R's documentation system, let alone
#' \pkg{roxygen2}, unless you have come to forge your code into a package.
#'
#' I am fully aware of the fact that \pkg{roxygen2} is meant to document
#' packages, not single code chunks.
#' So should you. Nevertheless I feel the temptation to use
#' roxygen2-style comments in code chunks that are not part of any package. And
#' to convert them to pdf for better readability.
#' @note This package is basically a wrapper to
#' \enumerate{
#'     \item \pkg{roxygen2}. It internally creates a temporary package from the
#'      code files provided (using
#'      \code{\link[utils:package.skeleton]{utils::package.skeleton}})
#'      which it then passes to roxygen2.
#'     \item 'R CMD' commands run by \pkg{callr}.
#' }
#' @seealso \pkg{docstring}
#' (\url{https://cran.r-project.org/package=docstring}) also creates temporary
#' help pages as well but using a different technical approach (allowing you to
#' view them in the \code{RStudio} help pane). But it creates them from python
#' style docstring-like comments it then parses into \pkg{roxygen2}. And it
#' does not write to file so far.
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @section Warning:
#' This package writes to disk, so \strong{NEVER} run it with superuser powers.
#' @name document-package
#' @aliases document-package
#' @docType package
#' @keywords package
NULL
