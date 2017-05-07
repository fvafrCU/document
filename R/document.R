#' Fake a Package From a Single Code File
#'
#' To build documentation for a single code file, we need a temporary package.
#' Of course the code file should contain \pkg{roxygen2} comments.
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @param file_name  The name of the R code file to be documented.
#' @param dependencies a character vector of package names the functions depend
#' on.
#' @param working_directory A working directory. Keep the default.
#' @param ... Arguments passed to \code{\link{get_lines_between_tags}}.
#' @return A string containing the path to the faked package.
#' @export
#' @examples
#' fake_package(file_name = system.file("tests", "files", "simple.R",
#'          package = "document"))
fake_package <- function(file_name, working_directory = NULL,
                         dependencies = NULL, ...) {
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
        warning("Couldn't find roxygen comments in file ", file_name, ".")
    }
    # need a hard coded basename here to ensure not replicating the input code
    # if faking for the same code file again.
    code_file <- file.path(working_directory, "code.R")
    writeLines(roxygen_code, con = code_file)
    suppressMessages(utils::package.skeleton(code_files = code_file,
                                             name = package_name,
                                             path = working_directory,
                                             force = TRUE))
    file.remove(code_file)
    # roxygen2 does not overwrite files not written by roxygen2, so we need to
    # delete some files
    file.remove(list.files(man_directory, full.names = TRUE))
    file.remove(file.path(package_directory, "NAMESPACE"))
    #% create documentation from roxygen comments for the package
    dev_null <- utils::capture.output(roxygen2::roxygenize(package.dir =
                                                           package_directory))
    if (! is.null(dependencies))
        add_dependencies_to_description(package_directory, dependencies)
    return(package_directory)
}
#' Document (Chunks of) an R Code File
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @inheritParams fake_package
#' @inheritParams write_the_docs
#' @param check_package Run R CMD check on the sources? See
#' \bold{Note} below.
#' @param output_directory The directory to put the documentation into.
#' @param clean Delete the working directory?
#' @param runit Convert the text received from the help files if running RUnit?
#' Do not bother, this is for Unit testing only.
#' @note One of the main features of 'R CMD check' is checking for 
#' code/documentation mismatches (it behaves pretty much like doxygen).
#' No build system can check whether your documentation is useful, but 'R CMD
#' check' checks if it is formally matching your code. This check is the basic 
#' idea behind \pkg{document}. The posibility to disable the R CMD check is
#' there to disable cpu consuming checks while testing the package. Stick with 
#' the default! 
#' And do not forget to export your functions using the line\cr
#' #' @export\cr
#' if you provide examples.
#' @return A list containing
#' \describe{
#'     \item{pdf_path}{The path to the pdf file produced.}
#'     \item{txt_path}{The path to the text file produced.}
#'     \item{html_path}{The path to the html file produced.}
#'     \item{check_result}{A list giving the R CMD check results.}
#' }
#' @export
#' @examples
#' \donttest{
#' res <- document(file_name = system.file("tests", "files", "minimal.R", 
#'                                         package = "document"), 
#'                 check_package = FALSE) # this is for the sake of CRAN cpu
#'                 # time only. _Always_ stick with the default!
#' 
#' # View R CMD check results.
#' cat(res[["check_result"]][["stdout"]], sep = "\n")
#' cat(res[["check_result"]][["stderr"]], sep = "\n")
#' 
#' # Copy docmentation to current working directory.
#' # This writes to your disk, so it's disabled. 
#' # Remove or comment out the next line to enable.
#' if (FALSE) 
#'     file.copy(res[["pdf_path"]], getwd())
#' }
document <- function(file_name,
                     working_directory = NULL,
                     output_directory = tempdir(),
                     dependencies = NULL, sanitize_Rd = TRUE, runit = FALSE,
                     check_package = TRUE, clean = FALSE, ...) {
    if (is.null(working_directory))
        working_directory <- file.path(tempdir(),
                                       paste0("document_",
                                              basename(tempfile(pattern = ""))))
    checkmate::assertFile(file_name, access = "r")
    checkmate::assertDirectory(output_directory, access = "r")
    checkmate::qassert(check_package, "B1")
    checkmate::qassert(working_directory, "S1")
    dir.create(working_directory, showWarnings = FALSE, recursive = TRUE)
    if (isTRUE(clean)) on.exit({
        unlink(working_directory, recursive = TRUE)
        options("document_package_directory" = NULL)
    })
    package_directory <- fake_package(file_name,
                                      working_directory = working_directory,
                                      dependencies = dependencies, ...)
    status <- write_the_docs(package_directory = package_directory,
                             file_name = file_name,
                             output_directory = output_directory,
                             dependencies = dependencies,
                             sanitize_Rd = sanitize_Rd, runit = runit)
    if (check_package) {
        # Get rid of one of R CMD checks' NOTEs
        file.remove(file.path(package_directory, "Read-and-delete-me"))
        clean_description(package_directory)
        # Use devtools::build to build in the package_directory.
        tgz <- devtools::build(package_directory, quiet = TRUE)
        # devtools::check's return value is crap, so use R CMD check via callr.
        tmp <- callr::rcmd_safe("check",
                                c(paste0("--output=", working_directory), tgz))
        status[["check_result"]] <- tmp
    }
    return(status)
}

#' Read R Documentation Files from a Package's Source, Convert and Write Them
#' to Disk
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @inheritParams fake_package
#' @param package_directory The directory containing the package's source.
#' @param output_directory The directory to put the documentation into.
#' @param runit Convert the text received from the help files if running RUnit?
#' @param sanitize_Rd Remove strange characters from \code{Rdconv}?
#' Do not bother, this is for Unit testing only.
#' on.
#' @return A list containing
#' \describe{
#'     \item{pdf_path}{The path to the pdf file produced.}
#'     \item{txt_path}{The path to the text file produced.}
#'     \item{html_path}{The path to the html file produced.}
#' }
write_the_docs <- function(package_directory, file_name,
                           output_directory = tempdir(),
                           dependencies = NULL, sanitize_Rd = TRUE,
                           runit = FALSE
                           ) {
    man_directory <- file.path(package_directory, "man")
    package_name <- basename(package_directory)
    html_name <- paste0(package_name, ".html")
    html_path <- file.path(output_directory, html_name)
    pdf_name <- paste0(package_name, ".pdf")
    pdf_path <- file.path(output_directory, pdf_name)
    txt_name <- paste0(package_name, ".txt")
    txt_path <- file.path(output_directory, txt_name)
    # TODO: make status depend on the status of the corresponding call to
    # rcmd_safe!
    status <- list(pdf_path = pdf_path, txt_path = txt_path,
                   html_path = html_path)
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
    # using R CMD Rdconv on the system instead of tools::Rd2... since
    # ?tools::Rd2txt states that
    # "These functions ... are mainly intended for internal use, their
    # interfaces are subject to change".
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
    writeLines(Rd_html, con = html_path)
    return(status)
}
#' A Convenience Wrapper to \code{getOption("document_package_directory")}
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @return \code{getOption("document_package_directory")}
#' @export
get_dpd <- function() return(getOption("document_package_directory"))
