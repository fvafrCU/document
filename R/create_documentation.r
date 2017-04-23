#' extract roxygen2-style and markdown comments from a single R code file
#'
#'  this is a wrapper around \code{\link{create_roxygen_documentation}} and
#'  \code{\link{create_markdown_documentation}}.
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 9bbb752b06d887f2115e37c3e9dadd89e40c49c7 $
#' @param file_name  name your R code file to be documented.
#' @param markdown set to FALSE if you do not want to parse markdown comments
#' in your file.
#' @param roxygen set to FALSE if you do not want to roxygenize your file.
#' @param ... arguments passed to \code{\link{create_roxygen_documentation}} or
#' \code{\link{create_markdown_documentation}}.
#' @return a logical vector indicating whether markdown comments and roxygen
#' annotations were parsed.
#' @examples
#' create_template(file_name = "my_r_file.r", type = "roxygen_markdown")
#' create_documentation("my_r_file.r", overwrite = TRUE)
create_documentation <- function(file_name,
                                 markdown = TRUE,
                                 roxygen = TRUE,
                                 ...
                                 ) {
    assertFile(file_name, access = "r")
    qassert(markdown, "B1")
    qassert(roxygen, "B1")
    if (length(file_name) == 0) {stop("give a file_name!")}
    status_markdown  <- status_roxygen <- FALSE

    dots <- list(...)
    roxygen_defaults <- append(formals(create_roxygen_documentation),
                               formals(get_lines_between_tags)
                               )
    markdown_defaults <- formals(create_markdown_documentation)
    known_defaults <- append(roxygen_defaults, markdown_defaults)
    if (! all(names(dots) %in% names(known_defaults))) {
        stop(paste("got unkown argument(s): ",
                   paste(names(dots)[! names(dots) %in% names(known_defaults)],
                         collapse = ", ")))
    }
    arguments <- append(list(file_name = file_name), dots)
    if (markdown) {
        use <- utils::modifyList(markdown_defaults, arguments)
        arguments_to_use <- use[names(use) %in% names(markdown_defaults)]
        # use only non-empty arguments
        arguments_to_use <- arguments_to_use[arguments_to_use != ""]
        status_markdown <- do.call("create_markdown_documentation",
                                   arguments_to_use)
    }
    if (roxygen) {
        use <- utils::modifyList(roxygen_defaults, arguments)
        arguments_to_use <- use[names(use) %in% names(roxygen_defaults)]
        # use only non-empty arguments
        arguments_to_use <- arguments_to_use[arguments_to_use != ""]
        status_roxygen <- do.call("create_roxygen_documentation",
                                  arguments_to_use)
    }
    status <- c(markdown = status_markdown, roxygen = status_roxygen)
    return(invisible(status))
}
#' roxygenize an R code file, output the documentation to pdf.
#'
#' extract the roxygen parts by using special tags in the code, then wrap
#' utils::package.skeleton() and roxygen2::roxygenize().
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 9bbb752b06d887f2115e37c3e9dadd89e40c49c7 $
#' @param file_name  The name of the R code file to be documented.
#' @param output_directory The directory to put the documentation into.
#' @param overwrite Overwrite an existing documentation file?
#' @param check_package Run R CMD check on the sources?
#' @param dependencies a character vector of package names the functions depend
#' on.
#' @param copy_tmp_files_to path to copy temporary files to. See Note. \cr This
#' parameter has no effect if make_check is not TRUE.
#' @param working_directory A working directory. Defaults to tempdir().
#' \bold{Warning} the working_directory will be recursively
#' \code{\link{unlink}}ed. You can erase your disk if you change the default!
#' @param ... Arguments passed to \code{\link{get_lines_between_tags}}.
#' @return TRUE if pdf creation is successfull, FALSE otherwise.
#' @examples
#' create_template(file_name = "my_r_file.r", type = "template")
#' create_roxygen_documentation("my_r_file.r", overwrite = TRUE)
create_roxygen_documentation <- function(
                                         file_name,
                                         output_directory = ".",
                                         overwrite = FALSE,
                                         check_package = TRUE,
                                         copy_tmp_files_to = dirname(tempdir()),
                                         working_directory = tempdir(),
                                         dependencies = NULL,
                                         ...
                                         ) {
    assertFile(file_name, access = "r")
    assertDirectory(output_directory, access = "r")
    qassert(overwrite, "B1")
    qassert(check_package, "B1")
    assertDirectory(copy_tmp_files_to, access = "r")
    assertCharacter(dependencies, null.ok = TRUE)
    qassert(working_directory, "S1")
    on.exit(unlink("Rd2.pdf"))
    #% define variables
    out_file_name <- sub(".Rnw$", ".r", basename(file_name))
    package_name <- gsub("_", ".",
                         sub(".[rRS]$|.Rnw$", "", out_file_name, perl = TRUE)
                         )
    man_directory <- file.path(working_directory, package_name, "man")
    package_directory <- file.path(working_directory, package_name)
    pdf_name <- sub("[rRS]$", "pdf", out_file_name)
    pdf_path <- file.path(output_directory, pdf_name)
    txt_name <- sub("[rRS]$", "txt", out_file_name)
    txt_path <- file.path(output_directory, txt_name)
    # out_file_name may contain underscores, which need to be escaped for LaTeX.
    file_name_tex <- gsub("_", "\\_", out_file_name, fixed = TRUE)
    pdf_title <- paste("\'Roxygen documentation for file", file_name_tex, "\'")
    if (.Platform$OS.type != "unix") { 
        ## on windows, R CMD Rd2pdf crashes with multi-word titles... I have no
        ## clue of the why.
        pdf_title <- file_name_tex
        ## man dir on windows must be in slashes... at least for R CMD Rd2pdf,
        ## again, I have no clue.
        man_directory <- sub("\\\\","/", man_directory)
    }
    R_CMD_pdf <- paste("R CMD Rd2pdf --no-preview --internals", "--title=",  
                       pdf_title, man_directory)
    # R CMD command line options mustn't have spaces around equal signs:
    R_CMD_pdf <- gsub("= ", "=", R_CMD_pdf)
    #% create temporary directory
    unlink(working_directory, recursive = TRUE)
    dir.create(working_directory)
    #% get the roxygen code
    roxygen_code <- get_lines_between_tags(file_name, ...)
    if (is.null(roxygen_code) || ! any(grepl("^#+'", roxygen_code))) {
        stop(paste("Couldn't find roxygen comments in file", file_name,
                   "\n You shoud set from_firstline and to_lastline to FALSE."))
    }
    #% write new file to disk
    writeLines(roxygen_code, con = file.path(working_directory, out_file_name))
    #% create a package from new file
    package.skeleton(code_files = file.path(working_directory, out_file_name),
                     name = package_name, path = working_directory,
                     force = TRUE)
    #% create documentation from roxygen comments for the package
    roxygenize(package.dir = package_directory)
    #% streamline the documentation
    fix_package_documentation(package_directory)
    add_dependencies_to_description(package_directory, dependencies)
    if (check_package) {
        #% check if the package compiles
        build_and_check_package(package_directory = package_directory,
                                copy_tmp_files_to = copy_tmp_files_to
                                )
    }
    #% create documentation from Rd-files
    ##% create pdf
    system(R_CMD_pdf, intern = FALSE, wait = TRUE)
    ##% create txt
    # using R CMD Rdconv on the system instead of Rd2txt since ?Rd2txt states
    # it's "mainly intended for internal use" and its interface is "subject to
    # change."
    Rd_txt <- NULL
    files  <- sort_unlocale(list.files(man_directory, full.names = TRUE))
    for (rd_file in files) {
        R_CMD_txt <- paste0("R CMD Rdconv --type=txt ", rd_file)
        Rd_txt <- c(Rd_txt, system(R_CMD_txt, intern = TRUE, wait = TRUE))
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
    # After R CMD check the documentation.Rcheck/tests/startup.Rs reads:
    # options(useFancyQuotes = FALSE)
    # Have I tried that yet?
    Rd_txt <- gsub("<e2><80><99>" ,"'", 
                   gsub("<e2><80><98>", "'", 
                        iconv(Rd_txt, to = "ASCII", mark = TRUE, sub = "byte")
                   )
    )
    writeLines(iconv(Rd_txt, to = "ASCII", mark = TRUE), con = txt_name)
    #% copy pdf to output_directory
    files_copied <- c(status_pdf = file.copy("Rd2.pdf",
                                             pdf_path,
                                             overwrite = overwrite),
                      status_txt =  
                      if (output_directory == ".") { TRUE }
                      else {
                          file.copy(txt_name,
                                    txt_path,
                                    overwrite = overwrite)
                      }
                      )
    return(invisible(all(files_copied)))
}

#' parse markdown comments.
#'
#' A wrapper to parse_markdown_comments.py.
#'
#' @note should normally be invoked via \code{\link{create_documentation}}.
#' You could also run the python code directly.
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 9bbb752b06d887f2115e37c3e9dadd89e40c49c7 $
#' @param file_name name of or path to the file to be parsed through
#' parse_markdown_comments.py.
#' @param python3 name of or path to a python3 binary.
#' @param comment_character the character indicating a comment line. In R this
#' is '#'. You only need to change it if you want to run this function on a
#' file containing code other than R. But then you might be better off using
#' parse_markdown_comments.py directly.
#' @param magic_character the magic character indicating a markdown comment.
#' @param arguments a character vector of further arguments passed to
#' parse_markdown_comments.py.
#' @return TRUE on success, FALSE otherwise.
create_markdown_documentation <- function(file_name, python3 = "python3",
                                          arguments = NA,
                                          magic_character = "%",
                                          comment_character = "#"
                                          ) {
    assertFile(file_name, access = "r")
    qassert(python3, "S1")
    assertCharacter(arguments, null.ok = TRUE)
    qassert(magic_character, "s1")
    qassert(comment_character, "S1")
    status <- FALSE
    if (is.na(magic_character)) {
        python_arguments <- "-h"
    } else {
        if (is.na(arguments)) python_arguments <- NULL
        else python_arguments  <- arguments
        python_arguments <- c(python_arguments,
                              paste0("-c '", comment_character, "'"),
                              paste0("-m '", magic_character, "'"),
                              file_name)
    }
    if (Sys.which(python3) == ""){
        if (.Platform$OS.type != "unix") {
            message(paste("on Microsoft systems you may try to specify",
                          "'python3' as something like",
                          "'c:/python34/python.exe'")
            )
            message("you may try to install python3 through something along", 
                    " the lines of:\n\n",
                    "\tpackage <- 'installr' \n",
                    "\tif (!require(package, character.only = TRUE))", 
                    " install.packages(package)\n",
                    "\turl <- 'https://www.python.org/ftp/python/",
                    "3.4.3/python-3.4.3.amd64.msi'\n",
                    "\tinstallr::install.URL(url)\n ")
        }
        stop(paste("can't locate", python3))
    } else {
        parser <- system.file(file.path("python", "parse_markdown_comments.py"),
                              package = "documentation"
                              )
        # on windows, blanks in parser break system command, if unquoted
        parser <- paste0("'", parser, "'")
        status <- system2(python3, args = c(parser, python_arguments))
        # parse_markdown_comments.py tries to tex the tex file. If it does not
        # succeed, we use the tools package.
        pdf_name <- paste(file_name, "_markdown.pdf", sep = "")
        tex_name <- paste(file_name, "_markdown.tex", sep = "")
        if (file.exists(tex_name) && ! file.exists(pdf_name)) {
            tools::texi2dvi(tex_name, pdf = TRUE, clean = TRUE)
        }
        # python exit code 0 corresponds to TRUE, values <> 0 correspond to
        # FALSE
        status <- ! as.logical(status)
    }
    return(status)
}

