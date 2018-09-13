library(testthat)
if (interactive()) {
    devtools::load_all()
} else {
    library("document")
}
glbt <- document:::get_lines_between_tags

context("files")
file_name  <- file.path(system.file("files",
                                    package = "document"),
                        "mini_mal.R")
res <- document(file_name, check_package = TRUE, runit = TRUE)
test_that("path", {
              options(useFancyQuotes = FALSE)
              current <- res[["txt_path"]]
              reference  <- file.path(tempdir(), "mini_mal.txt")
              expect_equal(current, reference)
                        }
)
test_that("existance", {
              current <- res[["txt_path"]]
              expect_true(file.exists(current))
}
)

context("expected files")
test_that("clean", {
              file_name  <- file.path(system.file("files",
                                                  package = "document"),
                                      "simple.R")
              expected_file <- file.path(system.file("expected_files",
                                                     package = "document"),
                                         "simple.txt")

              res <- document(file_name, clean = TRUE, runit = TRUE)
              current <- readLines(res[["txt_path"]])
              reference  <- readLines(expected_file)
              expect_equal(current, reference)
}
)
if (isTRUE(Sys.getenv("NOT_CRAN"))) {
test_that("simple", {
              options(useFancyQuotes = FALSE)
              file_name  <- file.path(system.file("files",
                                                  package = "document"),
                                      "simple.R")
              res <- document(file_name, check_package = TRUE, runit = TRUE)
              current <- checks(res[["check_result"]])
              expect_true(! any(current["errors"]))
              res <- document(file_name, check_package = TRUE, runit = TRUE,
                              check_as_cran = FALSE)
              current <- checks(res[["check_result"]])[["errors"]]
              expect_true(!current)
}
)
context("man")
test_that("from R file", {
              options(pager = switch(.Platform[["OS.type"]],
                                     "unix" = "cat", "console"))
              path <- system.file("files", "simple.R",
                                  package = "document")
              document::man(x = path, topic = "a_first_function")
              cfile <- file.path(get_dpd(), "man", "a_first_function.Rd")
              current <- utils::capture.output(tools::Rd2txt(cfile))
              rfile <- system.file("expected_files",
                                   "sanitized_a_first_function.txt",
                                   package = "document")
              reference  <- readLines(rfile)
              expect_equal(current, reference)
}
)
test_that("from R file missing topic", {
              path <- system.file("files", "simple.R",
                                  package = "document")
              error_message <-
                  paste0("Give either a path to an R documentation file or ",
                         "additionally give a topic.")
              expect_error(document::man(x = path), error_message)
}
)

test_that("from topic, missing package", {
              options("document_package_directory" = NULL)
              error_message <- paste("Give the path to a file as x",
                                     "and \"foo\" as topic.")
              expect_error(document::man(x = "foo"), error_message)
}
)
test_that("from Rd file", {
              options(pager = switch(.Platform[["OS.type"]],
                                     "unix" = "cat", "console"))
              path <- system.file("files", "simple.R",
                                  package = "document")
              document::document(file_name = path, check_package = FALSE)
              cfile <- file.path(get_dpd(), "man", "a_first_function.Rd")
              document::man(x = cfile)
              current <- utils::capture.output(tools::Rd2txt(cfile))
              rfile <- system.file("expected_files",
                                   "sanitized_a_first_function.txt",
                                   package = "document")
              reference  <- readLines(rfile)
              expect_equal(current, reference)
}
)
test_that("from topic", {
              options(pager = switch(.Platform[["OS.type"]],
                                     "unix" = "cat", "console"))
              path <- system.file("files", "simple.R",
                                  package = "document")
              document::document(file_name = path, check_package = FALSE)
              document::man(x = "a_first_function")
              cfile <- file.path(get_dpd(), "man", "a_first_function.Rd")
              current <- utils::capture.output(tools::Rd2txt(cfile))
              rfile <- system.file("expected_files",
                                   "sanitized_a_first_function.txt",
                                   package = "document")
              reference  <- readLines(rfile)
              expect_equal(current, reference)
}
)


context("utils")
test_that("fake package", {
              path <- system.file("files", "no_roxy.R",
                                  package = "document")
              expect_warning(f <- document:::fake_package(file_name = path))
              expect_true(file.exists(file.path(f, "DESCRIPTION")))
}
)
test_that("add deps", {
              path <- system.file("files", "minimal.R",
                                  package = "document")
              f <- fake_package(file_name = path, working_directory = NULL,
                                dependencies = "utils")
              lines <- readLines(file.path(f, "DESCRIPTION"))
              index <- grep("^Depends:", lines)
              current <- lines[c(index, index + 1)]
              reference <- c("Depends: ", "    utils")
              expect_equal(current, reference)
}
)
}
