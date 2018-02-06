#' Document (Chunks of) an R Code File
#'
#' @inheritParams fake_package
#' @inheritParams write_the_docs
#' @param check_package Run \command{R CMD check} the sources? See
#' \bold{Note} below.
#' @param check_as_cran Use the \command{--as-cran} flag with
#' \command{R CMD check}?
#' @param stop_on_check_not_passing Stop if \command{R CMD check} does not pass?
#' @param clean Delete the working directory?
#' @param debug For internal use only: Summarize errors for \command{travis}?
#' @note One of the main features of \command{R CMD check} is checking for
#' code/documentation mismatches (it behaves pretty much like
#' \command{doxygen}).
#' No build system can check whether your documentation is useful, but
#' \command{R CMD check}
#' checks if it is formally matching your code. This check is the basic
#' idea behind \pkg{document}. The possibility to disable the
#' \command{R CMD check} is
#' there to disable CPU consuming checks while testing the package. Stick with
#' the default!
#' And do not forget to export your functions using the line\cr
#' #' @export\cr
#' should you provide examples.
#' @return A list containing
#' \describe{
#'     \item{pdf_path}{The path to the pdf file produced,}
#'     \item{txt_path}{The path to the text file produced,}
#'     \item{html_path}{The path to the html file produced,}
#'     \item{check_result}{The return value of
#'     \code{\link[rcmdcheck:rcmdcheck]{rcmdcheck::rcmdcheck()}}}
#' }
#' @export
#' @examples
#' \donttest{
#' res <- document(file_name = system.file("files", "minimal.R",
#'                                         package = "document"),
#'                 check_package = FALSE) # this is for the sake of CRAN cpu
#'                 # time only. _Always_ stick with the default!
#'
#' # View R CMD check results. If we had set check_package to TRUE in the above
#' # example, we now could retrieve the check results via:
#' cat(res[["check_result"]][["output"]][["stdout"]], sep = "\n")
#' cat(res[["check_result"]][["output"]][["stderr"]], sep = "\n")
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
                     check_package = TRUE, check_as_cran = check_package,
                     stop_on_check_not_passing = check_package, clean = FALSE,
                     debug = TRUE, ...) {
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
        check <- check_package(package_directory = package_directory,
                               working_directory = working_directory,
                               check_as_cran = check_as_cran,
                               debug = debug,
                               stop_on_check_not_passing =
                                   stop_on_check_not_passing)
        status[["check_result"]] <- check
    }
    return(status)
}

#' Write Documentation to Disk
#'
#' Read R documentation files from a package's source, convert and write them
#' to disk.
#'
#' \code{file_name} will usually be provided by \code{\link{document}} as the
#' R code file's name. This may, differing from a (temporary) package's name,
#' contain underscores. If you use the functions directly: stick with the
#' default, in which case internally
#' the  \code{\link[base]{basename}} of your \code{package_directory} will be
#' used. This should be a good guess.
#' @inheritParams fake_package
#' @param file_name The name of the file where to write the documentation into.
#' See \strong{Details}.
#' @param package_directory The directory containing the package's source.
#' @param output_directory The directory to put the documentation into. You
#' might want to use \code{\link[base]{dirname}(file_name)}.
#' @param sanitize_Rd Remove strange characters from \code{Rdconv}?
#' @param runit Convert the text received from the help files if running
#' \pkg{RUnit}?
#' Do not bother, this is for Unit testing only.
#' @return A list containing
#' \describe{
#'     \item{pdf_path}{The path to the pdf file produced.}
#'     \item{txt_path}{The path to the text file produced.}
#'     \item{html_path}{The path to the html file produced.}
#' }
#' @keywords internal
write_the_docs <- function(package_directory, file_name = package_directory,
                           output_directory = tempdir(),
                           dependencies = NULL, sanitize_Rd = TRUE,
                           runit = FALSE
                           ) {
    man_directory <- file.path(package_directory, "man")
    base_name <- sub(".[rRS]$|.Rnw$", "", basename(file_name), perl = TRUE)
    html_name <- paste0(base_name, ".html")
    html_path <- file.path(output_directory, html_name)
    pdf_name <- paste0(base_name, ".pdf")
    pdf_path <- file.path(output_directory, pdf_name)
    txt_name <- paste0(base_name, ".txt")
    txt_path <- file.path(output_directory, txt_name)
    status <- list(pdf_path = NULL, txt_path = NULL,
                   html_path = NULL)
    # out_file_name may contain underscores, which need to be escaped for LaTeX.
    file_name_tex <- gsub("_", "\\_", basename(file_name), fixed = TRUE)
    pdf_title <- paste("'Roxygen documentation for file", file_name_tex, "\'")
    if (.Platform$OS.type != "unix") {
        # On windows, R CMD Rd2pdf crashes with multi word titles... I have no
        # clue of the why.
        pdf_title <- file_name_tex
        # Man dir on windows must be in slashes... at least for R CMD Rd2pdf,
        # again, I have no clue.
        man_directory <- gsub("\\\\", "/", man_directory)
    }
    if (! dir.exists(output_directory)) dir.create(output_directory)
    options("document_package_directory" = package_directory)
    rcmd_args <- c("--no-preview", "--internals", "--force",
                   paste0("--title=", pdf_title), paste0("--output=", pdf_path),
                   man_directory)
    call_pdf <- withr::with_dir(tempdir(),
                                callr::rcmd_safe("Rd2pdf", rcmd_args)
                                )
    if (! as.logical(call_pdf[["status"]])) status[["pdf_path"]]  <- pdf_path
    files  <- sort_unlocale(list.files(man_directory, full.names = TRUE))
    # using R CMD Rdconv on the system instead of tools::Rd2... since
    # ?tools::Rd2txt states that
    # "These functions ... are mainly intended for internal use, their
    # interfaces are subject to change".
    call_txt <- lapply(files,
                       function(x) callr::rcmd_safe("Rdconv",
                                                    c("--type=txt", x)))
    call_html <- lapply(files,
                        function(x) callr::rcmd_safe("Rdconv",
                                                     c("--type=html", x)))
    Rd_txt <- sapply(call_txt, function(x) return(x[["stdout"]]))
    Rd_html <- sapply(call_html, function(x) return(x[["stdout"]]))
    status_txt <- sapply(call_txt, function(x) return(x[["status"]]))
    status_html <- sapply(call_html, function(x) return(x[["status"]]))
    if (all(! as.logical(status_txt))) status[["txt_path"]]  <- txt_path
    if (all(! as.logical(status_html))) status[["html_path"]]  <- html_path

    if (isTRUE(sanitize_Rd)) Rd_txt <- gsub("_\b", "", Rd_txt, fixed = TRUE)
    if (isTRUE(runit)) Rd_txt <- Rd_txt_RUnit(Rd_txt)
    writeLines(Rd_txt, con = txt_path)
    writeLines(Rd_html, con = html_path)
    # only return paths for existing files
    status[! sapply(status[! sapply(status, is.null)], file.exists)] <- NULL
    return(status)

}

#' A Convenience Wrapper
#'
#' Just a wrapper to \code{\link[base]{getOption}("document_package_directory")}
#'
#' @return \code{getOption("document_package_directory")}
#' @export
get_dpd <- function() return(getOption("document_package_directory"))
