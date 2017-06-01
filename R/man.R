#' Display a Help Page From a File's Documentation
#'
#' Display a \code{\link[utils]{help}}-like page from an existing R 
#' documentation (*.Rd) file, a topic from a temporary package with the
#' \code{option("document_package_directory")} set or a topic from an R code
#' file containing \pkg{roxygen2} documentation.
#'
#' @param x One of the following:
#' \itemize{
#'     \item A path to an R documentation (*.Rd) file.
#'     \item A path to a  code file containing comments for \pkg{roxygen2}.
#'     \item A  \code{\link{help}} topic if
#'     \code{option("document_package_directory")} is set (by
#'     \code{\link{document}}).
#' }
#' @param topic A \code{\link{help}} topic if \code{x} is a path to a code file
#' containing comments for \pkg{roxygen2}.
#' @param force_Rd if \code{x} is a file's path, then \code{\link{is_Rd_file}}
#' is used to decide whether the file is an R documentation file and call
#' \code{\link{document}} otherwise. Set to TRUE to disable this check and force
#' the file to be assumed to be an R documentation file.
#' \code{\link{is_Rd_file}} may produce false negatives.
#' @return Invisibly the status of \code{\link{display_Rd}}.
#' @export
#' @examples
#' \donttest{
#' document(file_name = system.file("tests", "files", "minimal.R", 
#'          package = "document"), check_package = FALSE)
#' man("foo")
#' # this equivalent to
#' path <- system.file("tests", "files", "minimal.R", package = "document") 
#' document::man(x = path, topic = "foo")
#' }
man <- function(x, topic = NA, force_Rd = FALSE) {
    usage <- usage()
    if (file.exists(x)) {
        if (is_Rd_file(x) || ! identical(FALSE, force_Rd)) {
            status <- display_Rd(x)
        } else {
            if (is.na(topic)) {
                stop("Give either a path to an R documentation file or ",
                     "additionally give a topic.")
            } else {
                document(x, clean = FALSE, check_package = FALSE)
                package_directory <- getOption("document_package_directory")
                rd_file <- file.path(package_directory, "man",
                                     paste0(topic, ".Rd"))
                status <- display_Rd(rd_file)
            }
        }
    } else {
        package_directory <- getOption("document_package_directory")
        if (is.null(package_directory)) {
            stop("Give the path to a file as x and ", deparse(substitute(x)),
                 " as topic.\n", usage)
        } else {
                rd_file <- file.path(package_directory, "man",
                                     paste0(x, ".Rd"))
                status <- display_Rd(rd_file)
        }

    }
    return(invisible(status))
}

#' Return the Usage of a Function From Within the Function
#' 
#' Get a usage template for a function from within the function if you encounter
#' misguided usage, you can display the template.
#'
#' @param n A negative integer giving the number of from to frames/environments
#' to go back (passed as \code{which} to \code{\link{sys.call}}). Set to
#' \code{-2} if you want to encapsulate the call to \code{usage} into a function
#' (like \code{\link{print}} or \code{\link{assign}}) within the function you
#' want to obtain the usage for.
#' Use the \code{<-} assignment operator with the default, see \bold{examples}
#' below.
#' @param usage Give this functions usage (as a usage example \ldots) and exit? 
#' @return A character string giving the Usage as \code{\link{help}} would do.
#' @export
#' @examples
#' # usage with assignment operator:
#' foo <- function(x) {
#'     u <- usage()
#'     message("Usage is: ", u)
#' }
#' foo()
#'
#' # usage without assignment operator:
#' bar <- function(x) {
#'     message(usage(n = -2))
#' }
#' bar()
usage <- function(n = -1, usage = FALSE) {
    if (isTRUE(usage))
        stop("Usage: ", usage(n = -2))
    calling_function <- as.list(sys.call(which = n))[[1]]
    usage <- trimws(sub("^function ", deparse(calling_function),
             deparse(args(as.character(calling_function)))[1]))
    return(usage)
}

#' Check Whether a File is Probably an R Documentation File
#'
#' This is meant for internal use by \code{\link{man}}.
#'
#' @note The check might produce false negatives (erroneously assuming the file
#' is not an R documentation file).
#' @return TRUE if the file is probably an R documentation file, FALSE
#' otherwise.
#' @param x The path to the file to be checked.
is_Rd_file <- function(x) {
    has_ext <-  grepl("\\.Rd$", x)
    lines <- readLines(x)
    items <- c("name", "title", "usage")
    item <- items[1]
    pattern  <- paste0("^\\\\", item, "\\{")
    has_item <- vapply(items,
                       function(item) return(any(grepl(pattern, lines))),
                       logical(1))
    if (all(has_item) && has_ext) {
        status  <- TRUE
    } else {
        status  <- FALSE
    }
    return(status)
}

#' Display the Contents of an R Documentation File
#'
#' This is meant for internal use by \code{\link{man}}.
#'
#' @note The Contents are converted to text with \code{Rdconv} and then saved
#' to a temporary file which is then displayed using the R pager.
#' Using \code{\link{cat}} on the text would not allow for using different
#' pagers.
#'
#' @return The return value of removing the temporary file.
#' @param rd_file The path to the Rd file to be displayed.
display_Rd <- function(rd_file) {
    rd_out <- callr::rcmd_safe("Rdconv",
                     c("--type=txt", rd_file))[["stdout"]]
    rd_txt <- tempfile()
    writeLines(rd_out, con = rd_txt)
    file.show(rd_txt)
    status <- file.remove(rd_txt)
    return(status)
}
