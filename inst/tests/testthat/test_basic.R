if (interactive()) {
    devtools::load_all()
} else {
    library("document")
}
testthat::context("expected files")
testthat::test_that("simple", {
          output_directory <- file.path(tempdir(), "document_testthat_txt")
          unlink(output_directory, recursive = TRUE)
          dir.create(output_directory)
          file_name  <- file.path(system.file("tests", "expected_files", 
                                              package = "document"), "simple.txt")
          # create current
          options(useFancyQuotes = FALSE)
          input <- file.path(system.file("tests", "files", package = "document"),
                             sub("\\.txt", ".R", basename(file_name)))
          print(file_name)
          print(input)
          txt_name <- document(input, output_directory = output_directory,
                               check = FALSE, runit = TRUE)[["txt_path"]]
          current <- readLines(txt_name)
          reference  <- readLines(file_name)
          testthat::expect_equal(current, reference)
}
)
testthat::context("man")
testthat::test_that("from R file", {
          options(pager = switch(.Platform[["OS.type"]], "unix" = "cat", "console"))
          path <- system.file("tests", "files", "simple.R", package = "document")
          document::man(x = path, topic = "a_first_function")
          current <- utils::capture.output(tools::Rd2txt(file.path(get_dpd(), "man", "a_first_function.Rd")))
          reference  <- readLines(system.file("tests", "expected_files", "sanitized_a_first_function.txt", package = "document"))
          testthat::expect_equal(current, reference)
}
)
testthat::test_that("from topic", {
          options(pager = switch(.Platform[["OS.type"]], "unix" = "cat", "console"))
          path <- system.file("tests", "files", "simple.R", package = "document")
          document::document(file_name = path, check_package = FALSE)
          document::man(x = "a_first_function")
          current <- utils::capture.output(tools::Rd2txt(file.path(get_dpd(), "man", "a_first_function.Rd")))
          reference  <- readLines(system.file("tests", "expected_files", "sanitized_a_first_function.txt", package = "document"))
          testthat::expect_equal(current, reference)
}
)
