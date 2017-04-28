#' Fake a Package From a Single Code File
#'
#' To build documentation for a single code file, we need a temporary package.
#' Of course the code file should contain \pkg{roxygen2} comments.
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @param file_name  The name of the R code file to be documented.
#' @param check_package Run \code{\link[devtools]{check}} on the sources?
#' @param dependencies a character vector of package names the functions depend
#' on.
#' @param working_directory A working directory.
#' @param ... Arguments passed to \code{\link{get_lines_between_tags}}.
#' @return A string containing the path to the faked package.
#' @export
#' @examples
#' document(file_name = system.file("tests", "files", "simple.R",
#'          package = "document"), check_package = FALSE)
fake_package <- function(file_name, working_directory = NULL,
                         check_package = FALSE, dependencies = NULL, ...) {
    checkmate::assertCharacter(dependencies, null.ok = TRUE)
    # Work around default here to stay below line with of 80:
    if (is.null(working_directory))
        working_directory <- file.path(tempdir(),
                                       basename(tempfile(pattern = "")))
    package_name <- gsub("_", ".",
                         sub(".[rRS]$|.Rnw$", "", basename(file_name),
                             perl = TRUE)
                         )
    package_directory <- file.path(working_directory, package_name)
    man_directory <- file.path(package_directory, "man")
    dir.create(working_directory, showWarnings = FALSE, recursive = TRUE)
    roxygen_code <- get_lines_between_tags(file_name, ...)
    if (is.null(roxygen_code) || ! any(grepl("^#+'", roxygen_code))) {
        stop(paste("Couldn't find roxygen comments in file", file_name,
                   "\nYou shoud set from_firstline and to_lastline to FALSE."))
    }
    # need a hard coded basename here to ensure not replicating the input code
    # if faking for the same code file again.
    code_file <- file.path(working_directory, "code.R") 
    writeLines(roxygen_code, con = code_file)
    utils::package.skeleton(code_files = code_file,
                            name = package_name,
                            path = working_directory,
                            force = TRUE)
    # file.remove(code_file)
    # roxygen2 does not overwrite files not written by roxygen2, so we need to
    # delete some files
    file.remove(list.files(man_directory, full.names = TRUE))
    file.remove(file.path(package_directory, "NAMESPACE"))
    #% create documentation from roxygen comments for the package
    roxygen2::roxygenize(package.dir = package_directory)
    clean_description(package_directory)
    if (! is.null(dependencies))
        add_dependencies_to_description(package_directory, dependencies)
    return(package_directory)
}
#' roxygenize an R code file, output the documentation to pdf.
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @inheritParams fake_package
#' @param output_directory The directory to put the documentation into.
#' @param sanitize_Rd Remove strange characters from Rdconv?
#' @param clean Delete the working directory?
#' @param runit Convert the text received from the help files if running RUnit?
#' Do not bother, this is for Unit testing only.
#' on.
#' @return A list containing
#' \describe{
#'     \item{pdf_path}{The path to the pdf file produced.}
#'     \item{txt_path}{The path to the text file produced.}
#'     \item{html_path}{The path to the html file produced.}
#'     \item{check_result}{The value of \code{\link[devtools]{check}}.}
#' }
#' @export
#' @examples
#' document(file_name = system.file("tests", "files", "simple.R",
#'          package = "document"), check_package = FALSE)
document <- function(file_name,
                     #TODO: output_directory = dirname(file_name),
                     output_directory = tempdir(), check_package = TRUE,
                     working_directory = file.path(tempdir(), "document"),
                     dependencies = NULL, sanitize_Rd = TRUE, runit = FALSE, 
                     clean = FALSE, ...) {
    checkmate::assertFile(file_name, access = "r")
    checkmate::assertDirectory(output_directory, access = "r")
    checkmate::qassert(check_package, "B1")
    checkmate::qassert(working_directory, "S1")
    status <- list(pdf_path = NA, txt_path = NA, html_path = NA,
                   check_result = NA)
    if (isTRUE(clean)) on.exit({
        unlink(working_directory, recursive = TRUE)
        options("document_package_directory" = NULL)
    })
    package_directory <- fake_package(file_name,
                                      working_directory = working_directory,
                                      check_package = check_package,
                                      dependencies = dependencies, ...)
    man_directory <- file.path(package_directory, "man")
    package_name <- basename(package_directory)
    html_name <- paste0(package_name, ".html")
    html_path <- file.path(output_directory, html_name)
    pdf_name <- paste0(package_name, ".pdf")
    pdf_path <- file.path(output_directory, pdf_name)
    txt_name <- paste0(package_name, ".txt")
    txt_path <- file.path(output_directory, txt_name)
    # out_file_name may contain underscores, which need to be escaped for LaTeX.
    file_name_tex <- gsub("_", "\\_", basename(file_name), fixed = TRUE)
    pdf_title <- paste("'Roxygen documentation for file", file_name_tex, "\'")
    if (.Platform$OS.type != "unix") {
        # On windows, R CMD Rd2pdf crashes with multi word titles... I have no
        # clue of the why.
        pdf_title <- file_name_tex
        # Man dir on windows must be in slashes... at least for R CMD Rd2pdf,
        # again, I have no clue.
        man_directory <- sub("\\\\", "/", man_directory)
    }
    if (! dir.exists(output_directory)) dir.create(output_directory)
    options("document_package_directory" = package_directory)
    callr::rcmd_safe("Rd2pdf", c("--no-preview --internals --force",
                                 paste0("--title=", pdf_title),
                                 paste0("--output=", pdf_path), man_directory))
    status[["pdf_path"]] <- pdf_path
    # using R CMD Rdconv on the system instead of tools::Rd2txt since
    # ?tools::Rd2txt states it is
    # "mainly intended for internal use" and its interface is "subject to
    # change."
    Rd_txt <- NULL
    Rd_html <- NULL
    files  <- sort_unlocale(list.files(man_directory, full.names = TRUE))
    for (rd_file in files) {
        Rd_txt <- c(Rd_txt,
                    callr::rcmd_safe("Rdconv",
                                     c("--type=txt", rd_file))[["stdout"]])
        Rd_html <- c(Rd_html,
                     callr::rcmd_safe("Rdconv",
                                      c("--type=html", rd_file))[["stdout"]])
    }
    if (isTRUE(sanitize_Rd)) Rd_txt <- gsub("_\b", "", Rd_txt, fixed = TRUE)
    if (isTRUE(runit)) Rd_txt <- Rd_txt_RUnit(Rd_txt)
    writeLines(Rd_txt, con = txt_path)
    status[["txt_path"]] <- txt_path
    writeLines(Rd_html, con = html_path)
    status[["html_path"]] <- html_path
    if (check_package) {
        status[["check_result"]] <- devtools::check(package_directory)
    }
    return(status)
}

#' A Convenience Wrapper to \code{getOption("document_package_directory")}
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @return \code{getOption("document_package_directory")}
#' @export
get_dpd <- function() return(getOption("document_package_directory"))
