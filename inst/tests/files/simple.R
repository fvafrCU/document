#!/usr/bin/Rscript --vanilla
#' \emph{File} simple.R
#'
#' Provide a simple example of a file using roxygen and standard R comments.
#'
#' @author Dominik Cullmann <adc-r@@arcor.de>
#' @note This header will show up in the documentation, but it's got nothing to
#' do with the R statements below. Usually this is not intended.
#' @section Warning: DO NOT CHANGE THE FOLLWOWING THREE LINES.
#' @docType data
#' @name A Header for
NULL
# ROXYGEN_STOP

# load packages, load local code, define local functions, set options
# You should stick to that order: if you define a function of a name which
# is used as a (function) name in a package you load, you _do_ want your
# version to mask the packages' version. 

#% load packages
library("methods") # load an example package from the standard library


#% load local code
# This would usually be functions defined and stored away in files.
# For now we just we just create a file containing R options and
# and then source it.
cat(file = "tmp.R", "options(warn = 2) # treat warnings as errors \n")
source("tmp.R")

#% define local functions
# ROXYGEN_START

#' a first function example XXX
#'
#' This really is just an example, the function prints \code{utils::head()} and
#' \code{utils::str()} of the given \code{data.frame}.
#' @author Dominik Cullmann <adc-r@@arcor.de> 
#' @param df Name of a data.frame to ... do whatever needs to be done. 
#' @return NULL. This is no good. 
#' @export
#' @examples
#' data(iris, package = "datasets")
#' a_first_function(iris)
a_first_function <- function(df) {
    message(paste("# Structure of", deparse(substitute(df)), ":"))
    utils::str(df)
    message(paste("# Head of", deparse(substitute(df)), ":"))
    print(utils::head(df))
    return(invisible(NULL))
}
# ROXYGEN_STOP

#% set "global" options
# We overwrite (mask) the options set from the options file. Had we done
# it the other way round, we might be tempted to assume warn still to be
# set to one, albeit it would have been overwritten by the sourced code.
options(warn = 1)

#% Analysize the data
colMeans(iris[1:4])

#% collect garbage 
# We created a local options file on our file system, which we should
# remove now.
file.remove("tmp.R")
