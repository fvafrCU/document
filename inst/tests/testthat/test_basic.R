library(testthat)
if (interactive()) {
    devtools::load_all()
} else {
    library("document")
}
glbt <- document:::get_lines_between_tags
context("files")
file_name  <- file.path(system.file("tests",
                                    "files",
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
              file_name  <- file.path(system.file("tests",
                                                  "files",
                                                  package = "document"),
                                      "simple.R")
              expected_file <- file.path(system.file("tests",
                                                     "expected_files",
                                                     package = "document"),
                                         "simple.txt")

              res <- document(file_name, clean = TRUE, runit = TRUE)
              current <- readLines(res[["txt_path"]])
              reference  <- readLines(expected_file)
              expect_equal(current, reference)
}
)
test_that("simple", {
              options(useFancyQuotes = FALSE)
              file_name  <- file.path(system.file("tests",
                                                  "files",
                                                  package = "document"),
                                      "simple.R")
              res <- document(file_name, check_package = TRUE, runit = TRUE)
              current <- res[["check_result"]][["status"]]
              reference  <- 0
              expect_equal(current, reference)
}
)
context("man")
test_that("from R file", {
              options(pager = switch(.Platform[["OS.type"]],
                                     "unix" = "cat", "console"))
              path <- system.file("tests", "files", "simple.R",
                                  package = "document")
              document::man(x = path, topic = "a_first_function")
              cfile <- file.path(get_dpd(), "man", "a_first_function.Rd")
              current <- utils::capture.output(tools::Rd2txt(cfile))
              rfile <- system.file("tests", "expected_files",
                                   "sanitized_a_first_function.txt",
                                   package = "document")
              reference  <- readLines(rfile)
              expect_equal(current, reference)
}
)
test_that("from R file missing topic", {
              path <- system.file("tests", "files", "simple.R",
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
              path <- system.file("tests", "files", "simple.R",
                                  package = "document")
              document::document(file_name = path, check_package = FALSE)
              cfile <- file.path(get_dpd(), "man", "a_first_function.Rd")
              document::man(x = cfile)
              current <- utils::capture.output(tools::Rd2txt(cfile))
              rfile <- system.file("tests", "expected_files",
                                   "sanitized_a_first_function.txt",
                                   package = "document")
              reference  <- readLines(rfile)
              expect_equal(current, reference)
}
)
test_that("from topic", {
              options(pager = switch(.Platform[["OS.type"]],
                                     "unix" = "cat", "console"))
              path <- system.file("tests", "files", "simple.R",
                                  package = "document")
              document::document(file_name = path, check_package = FALSE)
              document::man(x = "a_first_function")
              cfile <- file.path(get_dpd(), "man", "a_first_function.Rd")
              current <- utils::capture.output(tools::Rd2txt(cfile))
              rfile <- system.file("tests", "expected_files",
                                   "sanitized_a_first_function.txt",
                                   package = "document")
              reference  <- readLines(rfile)
              expect_equal(current, reference)
}
)

context("file parsing")

test_that("simple", {
              path <- system.file("tests", "files", "simple.R",
                                  package = "document")
              current <- glbt(path, keep_tagged_lines = TRUE)
              reference <- readLines(system.file("tests", "expected_files",
                                                 "simple.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("foobar", {
              path <- system.file("tests", "files", "foobar.R",
                                  package = "document")
              current <- glbt(path)
              reference <- readLines(system.file("tests", "expected_files",
                                                 "foobar.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("foobar no tagged lines", {
              path <- system.file("tests", "files", "foobar.R",
                                  package = "document")
              current <- glbt(path, keep_tagged_lines = FALSE)
              reference <- readLines(system.file("tests", "expected_files",
                                                 "foobar_nl.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("foo", {
              path <- system.file("tests", "files", "foo.R",
                                  package = "document")
              current <- glbt(path)
              reference <- readLines(system.file("tests", "expected_files",
                                                 "foo.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("foo no tagged lines", {
              path <- system.file("tests", "files", "foo.R",
                                  package = "document")
              current <- glbt(path, keep_tagged_lines = FALSE)
              reference <- readLines(system.file("tests", "expected_files",
                                                 "foo_nl.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("bar", {
              path <- system.file("tests", "files", "bar.R",
                                  package = "document")
              current <- glbt(path)
              reference <- readLines(system.file("tests", "expected_files",
                                                 "bar.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("bar no tagged lines", {
              path <- system.file("tests", "files", "bar.R",
                                  package = "document")
              current <- glbt(path, keep_tagged_lines = FALSE)
              reference <- readLines(system.file("tests", "expected_files",
                                                 "bar_nl.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("no tagged lines", {
              path <- system.file("tests", "files", "minimal.R",
                                  package = "document")
              current <- glbt(path, keep_tagged_lines = FALSE)
              expect_equal(current, character(0))
}
)
test_that("no tagged lines, not_from", {
              path <- system.file("tests", "files", "minimal.R",
                                  package = "document")
              current <- glbt(path, from_first_line = FALSE)
              expect_equal(current, NULL)
}
)
context("utils")
test_that("fake package", {
              path <- system.file("tests", "files", "no_roxy.R",
                                  package = "document")
              expect_warning(f <- document:::fake_package(file_name = path))
              expect_true(file.exists(file.path(f, "DESCRIPTION")))
}
)
test_that("add deps", {
              path <- system.file("tests", "files", "minimal.R",
                                  package = "document")
              f <- fake_package(file_name = path, working_directory = NULL,
                                dependencies = "utils")
              lines <- readLines(file.path(f, "DESCRIPTION"))
              current <- grep("^Depends:", lines, value = TRUE)
              reference <- "Depends: utils"
              expect_equal(current, reference)
}
)
context("checking the package")
test_that("error on bug, not as cran", {
              options(useFancyQuotes = FALSE)
              file_name  <- file.path(system.file("tests",
                                                  "files",
                                                  package = "document"),
                                      "warn.R")
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
              file_name  <- file.path(system.file("tests",
                                                  "files",
                                                  package = "document"),
                                      "warn.R")
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
              file_name  <- file.path(system.file("tests",
                                                  "files",
                                                  package = "document"),
                                      "warn.R")
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
              file_name  <- file.path(system.file("tests",
                                                  "files",
                                                  package = "document"),
                                      "warn.R")
              expect_warning(
                             document(file_name, check_package = TRUE,
                                      runit = TRUE,
                                      stop_on_check_not_passing = FALSE,
                                      check_as_cran = FALSE)
                             )
}
)
