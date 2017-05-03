library(testthat)
if (interactive()) {
    devtools::load_all()
} else {
    library("document")
}
context("expected files")
test_that("simple", {
          output_directory <- file.path(tempdir(),
                                        "document_testthat_txt")
          unlink(output_directory, recursive = TRUE)
          dir.create(output_directory)
          file_name  <- file.path(system.file("tests",
                                              "expected_files",
                                              package = "document"),
                                  "simple.txt")
          # create current
          options(useFancyQuotes = FALSE)
          input <- file.path(system.file("tests", "files",
                                         package = "document"),
                             sub("\\.txt", ".R",
                                 basename(file_name)))
          print(file_name)
          print(input)
          txt_name <- document(input,
                               output_directory = output_directory,
                               check = FALSE,
                               runit = TRUE)[["txt_path"]]
          current <- readLines(txt_name)
          reference  <- readLines(file_name)
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
          current <- document:::get_lines_between_tags(path,
                                                       keep_tagged_lines = TRUE)
          reference <- readLines(system.file("tests", "expected_files",
                                             "simple.R", package = "document"))
          expect_equal(current, reference)
}
)
test_that("foobar", {
          path <- system.file("tests", "files", "foobar.R",
                              package = "document")
          current <- document:::get_lines_between_tags(path)
          reference <- readLines(system.file("tests", "expected_files",
                                             "foobar.R", package = "document"))
          expect_equal(current, reference)
}
)
test_that("foobar no tagged lines", {
          path <- system.file("tests", "files", "foobar.R",
                              package = "document")
          current <- document:::get_lines_between_tags(path,
                                                       keep_tagged_lines = F)
          reference <- readLines(system.file("tests", "expected_files",
                                             "foobar_nl.R",
                                             package = "document"))
          expect_equal(current, reference)
}
)
test_that("foo", {
          path <- system.file("tests", "files", "foo.R", package = "document")
          current <- document:::get_lines_between_tags(path)
          reference <- readLines(system.file("tests", "expected_files",
                                             "foo.R", package = "document"))
          expect_equal(current, reference)
}
)
test_that("foo no tagged lines", {
          path <- system.file("tests", "files", "foo.R", package = "document")
          current <- document:::get_lines_between_tags(path,
                                                       keep_tagged_lines = F)
          reference <- readLines(system.file("tests", "expected_files",
                                             "foo_nl.R", package = "document"))
          expect_equal(current, reference)
}
)
test_that("bar", {
          path <- system.file("tests", "files", "bar.R", package = "document")
          current <- document:::get_lines_between_tags(path)
          reference <- readLines(system.file("tests", "expected_files",
                                             "bar.R", package = "document"))
          expect_equal(current, reference)
}
)
test_that("bar no tagged lines", {
          path <- system.file("tests", "files", "bar.R", package = "document")
          current <- document:::get_lines_between_tags(path,
                                                       keep_tagged_lines = F)
          reference <- readLines(system.file("tests", "expected_files",
                                             "bar_nl.R", package = "document"))
          expect_equal(current, reference)
}
)
test_that("no tagged lines", {
          path <- system.file("tests", "files", "minimal.R",
                              package = "document")
          current <- document:::get_lines_between_tags(path,
                                                       keep_tagged_lines = F)
          expect_equal(current, character(0))
}
)
test_that("no tagged lines, not_from", {
          path <- system.file("tests", "files", "minimal.R",
                              package = "document")
          current <- document:::get_lines_between_tags(path,
                                                       from_first_line = FALSE)
          expect_equal(current, NULL)
}
)
