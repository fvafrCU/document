#' roxygenize an R code file, output the documentation to pdf.
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @param file_name  The name of the R code file to be documented.
#' @param output_directory The directory to put the documentation into.
#' @param check_package Run R CMD check on the sources?
#' @param runit Convert the text recieved from the help files if running RUnit?
#' Do not bother, this is for Unit testing only.
#' @param dependencies a character vector of package names the functions depend
#' on.
#' @param working_directory A working directory. 
#' \bold{Warning} the working_directory will be recursively
#' \code{\link{unlink}}ed. You can erase your disk if you change the default!
#' @param ... Arguments passed to \code{\link{get_lines_between_tags}}.
#' @return FIXME
#' @export
#' @examples
#' document(file_name = system.file("tests", "files", "simple.R", package = "document"),
#'          check_package = FALSE)
document <- function(file_name, 
                     #FIXME: output_directory = dirname(file_name),
                     output_directory = tempdir(),
                     check_package = TRUE, working_directory = tempdir(),
                     dependencies = NULL, runit = FALSE,
                     ...
                     ) {
    checkmate::assertFile(file_name, access = "r")
    checkmate::assertDirectory(output_directory, access = "r")
    checkmate::qassert(check_package, "B1")
    checkmate::assertCharacter(dependencies, null.ok = TRUE)
    checkmate::qassert(working_directory, "S1")
    status <- list(pdf_path = NA, txt_path = NA, check_result = NA)
    out_file_name <- sub(".Rnw$", ".r", basename(file_name))
    package_name <- gsub("_", ".",
                         sub(".[rRS]$|.Rnw$", "", out_file_name, perl = TRUE)
                         )
    physical_package_name <- paste("document", package_name, 
                                    basename(tempfile(pattern = "")), sep = ".")
    package_directory <- file.path(working_directory, physical_package_name)
    options("document_package_directory" = package_directory)
    man_directory <- file.path(package_directory, "man")
    pdf_name <- sub("[rRS]$", "pdf", out_file_name)
    pdf_path <- file.path(output_directory, pdf_name)
    txt_name <- sub("[rRS]$", "txt", out_file_name)
    txt_path <- file.path(output_directory, txt_name)
    # out_file_name may contain underscores, which need to be escaped for LaTeX.
    file_name_tex <- gsub("_", "\\_", out_file_name, fixed = TRUE)
    pdf_title <- paste("'Roxygen documentation for file", file_name_tex, "\'")
    if (.Platform$OS.type != "unix") { 
        ## on windows, R CMD Rd2pdf crashes with multi-word titles... I have no
        ## clue of the why.
        pdf_title <- file_name_tex
        ## man dir on windows must be in slashes... at least for R CMD Rd2pdf,
        ## again, I have no clue.
        man_directory <- sub("\\\\","/", man_directory)
    }
    dir.create(working_directory)
    if (! dir.exists(output_directory)) dir.create(output_directory)
    roxygen_code <- get_lines_between_tags(file_name, ...)
    if (is.null(roxygen_code) || ! any(grepl("^#+'", roxygen_code))) {
        stop(paste("Couldn't find roxygen comments in file", file_name,
                   "\nYou shoud set from_firstline and to_lastline to FALSE."))
    }
    #% write new file to disk
    writeLines(roxygen_code, con = file.path(working_directory, out_file_name))
    #% create a package from new file
    utils::package.skeleton(code_files = file.path(working_directory, 
                                                   out_file_name),
                            name = physical_package_name, path = working_directory,
                            force = TRUE)
    # roxygen2 does not overwrite files not written by roxygen2, so we need to
    # delete some files
    file.remove(list.files(man_directory, full.names = TRUE)) 
    file.remove(file.path(package_directory, "NAMESPACE")) 
    #% create documentation from roxygen comments for the package
    roxygen2::roxygenize(package.dir = package_directory)
    clean_description(package_directory)
    if (! is.null(dependencies)) 
        add_dependencies_to_description(package_directory, dependencies)
    callr::rcmd_safe("Rd2pdf", c("--no-preview --internals --force", 
                                 paste0("--title=", pdf_title),  
                                 paste0("--output=", pdf_path), man_directory))
    status[["pdf_path"]] <- pdf_path
    # using R CMD Rdconv on the system instead of Rd2txt since ?Rd2txt states
    # it's "mainly intended for internal use" and its interface is "subject to
    # change."
    Rd_txt <- NULL
    files  <- sort_unlocale(list.files(man_directory, full.names = TRUE))
    for (rd_file in files) {
        Rd_txt <- c(Rd_txt, 
                    callr::rcmd_safe("Rdconv", 
                                     c("--type=txt", rd_file))[["stdout"]])
    }
    if(isTRUE(runit)) Rd_txt <- Rd_txt_RUnit(Rd_txt)
    writeLines(Rd_txt, con = txt_path)
    status[["txt_path"]] <- txt_path
    if (check_package) {
        status[["check_result"]] <- devtools::check(package_directory)
    }
    return(status)
}
