library(testthat)
if (interactive()) {
    devtools::load_all()
} else {
    library("document")
}
context("files")
file_name  <- file.path(system.file("tests",
                                    "files",
                                    package = "document"),
                        "mini_mal.R")
res <- document(file_name, check_package = TRUE, runit = TRUE, debug = TRUE, stop_on_check_not_passing = TRUE)
