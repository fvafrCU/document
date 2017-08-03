devtools::load_all()
file_name  <- file.path(system.file("tests",
                                    "files",
                                    package = "document"),
                        "warn.R")
working_directory = NULL;
output_directory = tempdir();
dependencies = NULL; sanitize_Rd = TRUE; runit = FALSE;
check_package = TRUE; check_as_cran = check_package; 
stop_on_check_not_passing = TRUE; clean = FALSE;

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
                                      dependencies = dependencies)
    status <- write_the_docs(package_directory = package_directory,
                             file_name = file_name,
                             output_directory = output_directory,
                             dependencies = dependencies,
                             sanitize_Rd = sanitize_Rd, runit = runit)
        # Get rid of one of R CMD checks' NOTEs
        file.remove(file.path(package_directory, "Read-and-delete-me"))
        clean_description(package_directory)
        # Use devtools::build to build in the package_directory.
        tgz <- devtools::build(package_directory, quiet = TRUE)
        # devtools::check's return value is crap, so use R CMD check via callr.
        check_args  <- c(paste0("--output=", working_directory), tgz)
        if (isTRUE(check_as_cran)) {
            check_args <- c("--as-cran", check_args) 
            # "checking CRAN incoming feasibility" will cause a NOTE
            expectation <- "Status: 1 NOTE"
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
                message(paste(.libPaths(), collapse = "\n"))
        libpath <- .libPaths()[length(.libPaths())]
        tmp <- callr::rcmd_safe("check", cmdargs = check_args, 
                                libpath = libpath)
        check_log <- unlist(strsplit(tmp[["stdout"]], split = "\n"))
        i = grep("WARNING|ERROR|NOTE", check_log)
        i = unlist(lapply(i, function(x) return(seq(from = x, length.out = 7))))
        i <- i[i <= length(check_log)]
        rule <- "================="
        message(paste(c(rule, check_log[i], rule), collapse  ="\n"))
        vapply(i, function(x) return(seq(from = x, length.out = 3)), numeric())


                rule <- "###"
                message(paste(c(rule, check_log[length(check_log)], expectation), collapse = "\n"))
                message(paste(c(rule, .libPaths()), collapse = "\n"))
                message(paste(c(rule, check_log[i], rule), collapse  ="\n"))

res <- document(file_name, check_package = TRUE, runit = TRUE)
