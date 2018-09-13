if (isTRUE(Sys.getenv("NOT_CRAN"))) {
library(testthat)
if (interactive()) {
    devtools::load_all()
} else {
    library("document")
}
glbt <- document:::get_lines_between_tags

context("file parsing")
test_that("simple", {
              path <- system.file("files", "simple.R",
                                  package = "document")
              current <- glbt(path, keep_tagged_lines = TRUE)
              reference <- readLines(system.file("expected_files",
                                                 "simple.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("foobar", {
              path <- system.file("files", "foobar.R",
                                  package = "document")
              current <- glbt(path)
              reference <- readLines(system.file("expected_files",
                                                 "foobar.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("foobar no tagged lines", {
              path <- system.file("files", "foobar.R",
                                  package = "document")
              current <- glbt(path, keep_tagged_lines = FALSE)
              reference <- readLines(system.file("expected_files",
                                                 "foobar_nl.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("foo", {
              path <- system.file("files", "foo.R",
                                  package = "document")
              current <- glbt(path)
              reference <- readLines(system.file("expected_files",
                                                 "foo.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("foo no tagged lines", {
              path <- system.file("files", "foo.R",
                                  package = "document")
              current <- glbt(path, keep_tagged_lines = FALSE)
              reference <- readLines(system.file("expected_files",
                                                 "foo_nl.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("bar", {
              path <- system.file("files", "bar.R",
                                  package = "document")
              current <- glbt(path)
              reference <- readLines(system.file("expected_files",
                                                 "bar.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("bar no tagged lines", {
              path <- system.file("files", "bar.R",
                                  package = "document")
              current <- glbt(path, keep_tagged_lines = FALSE)
              reference <- readLines(system.file("expected_files",
                                                 "bar_nl.R",
                                                 package = "document"))
              expect_equal(current, reference)
}
)
test_that("no tagged lines", {
              path <- system.file("files", "minimal.R",
                                  package = "document")
              current <- glbt(path, keep_tagged_lines = FALSE)
              expect_equal(current, character(0))
}
)
test_that("no tagged lines, not_from", {
              path <- system.file("files", "minimal.R",
                                  package = "document")
              current <- glbt(path, from_first_line = FALSE)
              expect_equal(current, NULL)
}
)
}
