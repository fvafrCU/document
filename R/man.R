#' XXX: view a help page from a file documentation
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @param x A XXX:
#' @param topic XXX:
#' @param force_Rd XXX:
#' @return Invisibly XXX:
#' @export
#' @examples
#' document(file_name = system.file("tests", "files", "simple.R", package = "document"), 
#'          check_package = FALSE)
#' man("a_first_function")
man <- function(x, topic = NA, force_Rd = FALSE) {
    usage <- usage()
    if (file.exists(x)) {
        if (is_Rd_file(x) && ! identical(FALSE, force_Rd)) {
            status <- show_Rd(x)
        } else {
            if (! is.na(topic)) {
                stop("Give either a path to an R documentation file or ", 
                     "additionally give a topic.")
            } else {
                document(x)
                package_directory = getOption("document_package_directory")
                rd_file <- file.path(package_directory, "man", 
                                     paste0(topic, ".Rd"))
                status <- show_Rd(rd_file)
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
                status <- show_Rd(rd_file)
        }

    }
}
#' Return the Usage of a Function From Within the Function
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @return A character string giving the Usage as \code{\link{help}} would do.
#' @note Do not encapsulate it inside a function like \code{\link{print}} or
#' \code{\link{assign}} since it will then return that function's Usage. Use the
#' \code{<-} assignment operator.
#' @export
#' @examples
#' foo <- function(x){
#'     u <- usage()
#'     message("Usage is: ", u)
#' }
#' foo()
usage <- function() {
    calling_function = as.list(sys.call(-1))[[1]]
    useage <- trimws(sub("^function ", calling_function, 
             deparse(args(as.character(calling_function)))[1]))
    return(useage)
}
#' XXX:
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @return XXX:
#' @param x XXX:
#' @export
#' @examples
#' warning("non given")
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

#' XXX:
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @return XXX:
#' @param rd_file XXX:
#' @export
#' @examples
#' warning("non given")
show_Rd <- function(rd_file) {
    rd_out <- callr::rcmd_safe("Rdconv", 
                     c("--type=txt", rd_file))[["stdout"]]
    rd_txt <- tempfile()
    writeLines(rd_out, con = rd_txt)
    file.show(rd_txt) 
    status <- file.remove(rd_txt)
    return(status)
}
