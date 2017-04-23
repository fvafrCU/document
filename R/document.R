#' roxygenize an R code file, output the documentation to pdf.
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 9bbb752b06d887f2115e37c3e9dadd89e40c49c7 $
#' @param file_name  The name of the R code file to be documented.
#' @param output_directory The directory to put the documentation into.
#' @param clean Delete the working direcotry?
#' @param check_package Run R CMD check on the sources?
#' @param dependencies a character vector of package names the functions depend
#' on.
#' @param working_directory A working directory. Defaults to tempdir().
#' \bold{Warning} the working_directory will be recursively
#' \code{\link{unlink}}ed. You can erase your disk if you change the default!
#' @param ... Arguments passed to \code{\link{get_lines_between_tags}}.
#' @return TRUE if pdf creation is successfull, FALSE otherwise.
#' @export
#' @examples
#' document(file_name = system.file("tests", "files", "simple.R", package = "document"))
document <- function(file_name, output_directory = ".", clean = FALSE,
                     check_package = TRUE, working_directory = tempfile(),
                     dependencies = NULL,
                     ...
                     ) {
    checkmate::assertFile(file_name, access = "r")
    checkmate::assertDirectory(output_directory, access = "r")
    checkmate::qassert(check_package, "B1")
    checkmate::assertCharacter(dependencies, null.ok = TRUE)
    checkmate::qassert(working_directory, "S1")



    out_file_name <- sub(".Rnw$", ".r", basename(file_name))
    package_name <- gsub("_", ".",
                         sub(".[rRS]$|.Rnw$", "", out_file_name, perl = TRUE)
                         )
    package_directory <- file.path(working_directory, package_name)
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
    if (isTRUE(clean)) on.exit(unlink(working_directory, recursive = TRUE), 
                               add = TRUE)
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
                            name = package_name, path = working_directory,
                            force = TRUE)
    #% create documentation from roxygen comments for the package
    roxygen2::roxygenize(package.dir = package_directory)
    fix_package_documentation(package_directory)
    add_dependencies_to_description(package_directory, dependencies)
    callr::rcmd_safe("Rd2pdf", c("--no-preview --internals --force", 
                                 paste0("--title=", pdf_title),  
                                 paste0("--output=", pdf_path), man_directory))
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
    # TODO: this is dreadful, I'm converting non-ascii to byte and that back to
    # ascii again, but 
    # - setting the options(useFancyQuotes = 'UTF-8') and 
    # - gsub("\u0060", "'", Rd_txt) (I thought u0060 would be the backtick)
    # didn't seem to help. 
    # Why am I doing this? It want to run RUnit tests from within R CMD check
    # and interactively. Files produced are compared with expected files. Now R
    # CMD check and interactive (and batch) give different encodings. I don't
    # know why, but they do. 
    # After R CMD check the XXX.Rcheck/tests/startup.R reads:
    # options(useFancyQuotes = FALSE)
    # Have I tried that yet?
    Rd_txt <- gsub("<e2><80><99>" ,"'", 
                   gsub("<e2><80><98>", "'", 
                        iconv(Rd_txt, to = "ASCII", mark = TRUE, sub = "byte")
                        )
                   )
    writeLines(iconv(Rd_txt, to = "ASCII", mark = TRUE), con = txt_path)
    if (check_package) {
        check <- devtools::check(package_directory)
    }

    return(invisible())
}
