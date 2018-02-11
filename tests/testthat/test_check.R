library(testthat)
if (interactive()) {
    devtools::load_all()
} else {
    library("document")
}

probably_winbuilder <- function() {
    # See file fixme_test_check.txt
    r <- identical(.Platform[["OS.type"]], "windows")
    return(r)
}

glbt <- document:::get_lines_between_tags

context("checking the package")
test_that("error on bug, not as cran", {
              options(useFancyQuotes = FALSE)
              file_name  <- file.path(system.file("files",
                                                  package = "document"),
                                      "produce_warning.R")
              if (! probably_winbuilder())
                  expect_error(
                               document(file_name, check_package = TRUE,
                                        runit = TRUE,
                                        stop_on_check_not_passing = TRUE,
                                        check_as_cran = FALSE)
                               )
}
)
test_that("error on bug, as cran", {
              options(useFancyQuotes = FALSE)
              file_name  <- file.path(system.file("files",
                                                  package = "document"),
                                      "produce_warning.R")
              if (! probably_winbuilder())
                  expect_error(
                               document(file_name, check_package = TRUE,
                                        runit = TRUE,
                                        stop_on_check_not_passing = TRUE,
                                        check_as_cran = TRUE)
                               )
}
)
test_that("warning on bug, not as cran", {
              options(useFancyQuotes = FALSE)
              file_name  <- file.path(system.file("files",
                                                  package = "document"),
                                      "produce_warning.R")
              if (! probably_winbuilder())
                  expect_warning(
                                 document(file_name, check_package = TRUE,
                                          runit = TRUE,
                                          stop_on_check_not_passing = FALSE,
                                          check_as_cran = TRUE)
                                 )
}
)
test_that("warning on bug, as cran", {
              options(useFancyQuotes = FALSE)
              file_name  <- file.path(system.file("files",
                                                  package = "document"),
                                      "produce_warning.R")
              if (! probably_winbuilder())
                  expect_warning(
                                 document(file_name, check_package = TRUE,
                                          runit = TRUE,
                                          stop_on_check_not_passing = FALSE,
                                          check_as_cran = FALSE)
                                 )
}
)
