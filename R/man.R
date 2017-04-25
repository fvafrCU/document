#' view a help page from a file documentation
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @param fun A string giving the name of the function.
#' @return Invisibly NULL
#' @export
#' @examples
#' document(file_name = system.file("tests", "files", "simple.R", package = "document"), 
#'          check_package = FALSE)
#' man("a_first_function")
man <- function(fun) {
    package_directory = getOption("document_package_directory")
    rd_file <- file.path(package_directory, "man", paste0(fun, ".Rd"))
    rd_out <- callr::rcmd_safe("Rdconv", 
                     c("--type=txt", rd_file))[["stdout"]]
    rd_txt <- tempfile()
    writeLines(rd_out, con = rd_txt)
    file.show(rd_txt) 
    return(invisible(NULL))
}

