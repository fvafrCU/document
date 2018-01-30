devtools::load_all()
file_name  <- file.path(system.file("tests",
                                    "files",
                                    package = "document"),
                        "warn.R")
res <- document(file_name, check_package = TRUE, runit = TRUE, debug = TRUE)
# gabor
devtools::load_all()
file_name = system.file("tests", "files", "minimal.R", package = "document")
working_directory <- NULL
if (is.null(working_directory))
    working_directory <- file.path(tempdir(),
                                   paste0("document_",
                                          basename(tempfile(pattern = ""))))
package_directory <- fake_package(file_name, working_directory = working_directory)
check_as_cran = TRUE
stop_on_check_not_passing = TRUE
debug = TRUE
check_log <- unlist(strsplit(res[["stdout"]], split = "\n"))
roxygen2::roxygenize(package.dir = package_directory)
res_rc <- rcmdcheck::rcmdcheck(path = package_directory, args = "--as-cran")
res <- callr::rcmd_safe("check", cmdargs = check_args,
                        libpath = libpath)

