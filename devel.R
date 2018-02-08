devtools::load_all()
file_name  <- system.file("files", "produce_warning.R", package = "document")
devtools::load_all()
working_directory <- NULL
if (is.null(working_directory))
    working_directory <- file.path(tempdir(),
                                   paste0("document_",
                                          basename(tempfile(pattern = ""))))
package_directory <- fake_package(file_name, working_directory = working_directory)
r <- rcmdcheck::rcmdcheck(path = package_directory, args = "--as-cran")
print(str(r))
d <- document::check_package(package_directory, working_directory,
                          check_as_cran = TRUE,
                          stop_on_check_not_passing = FALSE, debug = TRUE)


