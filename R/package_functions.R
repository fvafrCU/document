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
#' @keywords internal
#' @examples
#' document:::fake_package(file_name = system.file("files", "simple.R",
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
#' This is a wrapper to \code{\link[rcmdcheck:rcmdcheck]{rcmdcheck::rcmdcheck}},
#' signaling notes, warnings and errors.
#' @inheritParams write_the_docs
#' @inheritParams document
#' @keywords internal
#' @return The return value of
#' \code{\link[rcmdcheck:rcmdcheck]{rcmdcheck::rcmdcheck}}.
check_package <- function(package_directory, working_directory,
                          check_as_cran = TRUE,
                          stop_on_check_not_passing = FALSE, debug = TRUE) {
        # Get rid of one of R CMD checks' NOTEs
        file.remove(file.path(package_directory, "Read-and-delete-me"))
        clean_description_file(package_directory)
        check_args  <- NULL
        if (isTRUE(check_as_cran)) check_args <- c("--as-cran", check_args)
        res <- rcmdcheck::rcmdcheck(path = package_directory,
                                    libpath = .libPaths(),
                                    args = check_args)
        has_errors <- as.logical(length(res[["errors"]]))
        has_warnings <- as.logical(length(res[["warnings"]]))
        has_notes <- as.logical(length(res[["notes"]]))
        if (isTRUE(stop_on_check_not_passing)) {
            # NOTE: WARNING - potential bug, I do not understand why
            # find.package using .libPaths() does not find MASS,
            # when running the _tests_ via R CMD check (and only then).
            # R CMD check warns:
            #
            # > * checking Rd cross-references ... WARNING
            # > Error in find.package(package, lib.loc) :
            # >   there is no package called ‘MASS’
            # > Calls: <Anonymous> -> lapply -> FUN -> find.package
            # > Execution halted
            # So:
            cheat_warnings_as_not_errors <- TRUE
            if (has_errors || (has_warnings && !cheat_warnings_as_not_errors)) {
                check_log <- res[["output"]][["stdout"]]
                message(paste(check_log, collpase = "\n"))
                if (isTRUE(debug)) {
                    i <- grep("WARNING|ERROR|NOTE", check_log)
                    i <- unlist(lapply(i,
                                       function(x) return(seq(from = x,
                                                              length.out = 7)))
                    )
                    i <- i[i <= length(check_log)]
                    rule <- "###"
                    m <- c(rule, paste("Got:", check_log[length(check_log)]),
                           .libPaths(), check_log[i], "Sys.info:",
                           as.character(Sys.info()[c("nodename",
                                                     "version")]),
                           paste("Path:", package_directory), rule)
                    message(paste(m, collapse = "\n"))
                }
                throw("R CMD check failed, read the above log and fix.")
            } else {
                if (has_notes) {
                    warn("R CMD check had NOTES, read the log an fix.")

                }
            }
        } else {
            if (has_errors || has_warnings) {
                warn("R CMD check failed, read the log and fix.")
            } else {
                if (has_notes) {
                    warn("R CMD check had NOTES, read the log an fix.")
                }
            }
        }
        return(res)
}
