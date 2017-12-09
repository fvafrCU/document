#' Fake a Package From a Single Code File
#'
#' To build documentation for a single code file, we need a temporary package.
#' Of course the code file should contain \pkg{roxygen2} comments.
#' @param file_name  The name of the R code file to be documented.
#' @param dependencies A character vector of package names the functions depend
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
    if (! is.null(dependencies)) {
        dependency_data <- data.frame(type = "Depends", package = dependencies,
                                      version = "*")
        d <- desc::description$new(package_directory)
        d$set_deps(dependency_data)
        d$write()
    }
    return(package_directory)
}

#' Run \command{R CMD check} on a Package Directory
#'
#' @inheritParams write_the_docs
#' @inheritParams document
#' @return The return value of \command{R CMD check} ran through
#' \code{callr::rcmd_safe()}.
#' @export
check_package <- function(package_directory, working_directory,
                          check_as_cran = TRUE,
                          stop_on_check_not_passing = TRUE, debug = TRUE) {
        # Get rid of one of R CMD checks' NOTEs
        file.remove(file.path(package_directory, "Read-and-delete-me"))
        clean_description_file(package_directory)
        # Use devtools::build to build in the package_directory.
        tgz <- devtools::build(package_directory, quiet = TRUE)
        # devtools::check's return value is crap, so use R CMD check via callr.
        check_args  <- c(paste0("--output=", working_directory), tgz)
        if (isTRUE(check_as_cran)) {
            check_args <- c("--as-cran", check_args)
            is_probably_cran <- any(grepl("travis", .libPaths()))
            if (! is_probably_cran) {
                # "checking CRAN incoming feasibility" will cause a NOTE
                expectation <- "Status: 1 NOTE"
            } else {
                # but not on travis ...
                expectation <- "Status: OK"
            }
        } else {
            expectation <- "Status: OK"
        }
        # When running the tests via R CMD check, libPath()'s first element is a
        # path to a temporary library. callr::rcmd_safe() seems to only read the
        # first element of its libpath argument, and then R CMD check warns:
        #
        # > * checking Rd cross-references ... WARNING
        # > Error in find.package(package, lib.loc) :
        # >   there is no package called ‘MASS’
        # > Calls: <Anonymous> -> lapply -> FUN -> find.package
        # > Execution halted
        #
        # We could ignore this, but checking the log on the existance of
        # warnings to stop_on_check_not_passing does not work then. So:
        libpath <- .libPaths()[length(.libPaths())]
        res <- callr::rcmd_safe("check", cmdargs = check_args,
                                libpath = libpath)
        check_log <- unlist(strsplit(res[["stdout"]], split = "\n"))
        if (check_log[length(check_log)] != expectation) {
            if (isTRUE(stop_on_check_not_passing)) {
                message(paste(check_log, collapse = "\n"))
                if (isTRUE(debug)) {
                    i <- grep("WARNING|ERROR|NOTE", check_log)
                    i <- unlist(lapply(i,
                                      function(x) return(seq(from = x,
                                                             length.out = 7))))
                    i <- i[i <= length(check_log)]
                    rule <- "###"
                    m <- c(rule, paste("Got:", check_log[length(check_log)]),
                           paste("Expected:", expectation),
                           .libPaths(), check_log[i], "Sys.info:",
                           as.character(Sys.info()[c("nodename",
                                                     "version")]),
                           paste("Path:", package_directory), rule)
                    message(paste(m, collapse = "\n"))
                }
                throw("R CMD check failed, read the above log and fix.")
            } else {
                warn("R CMD check failed, read the log and fix.")
            }
        }
        return(res)
}
