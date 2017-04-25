if (interactive()) {
    devtools::load_all()
} else {
    library("document")
}
library("testthat")
context("expected files")
test_that("simple", {
    output_directory <- file.path(tempdir(), "document_testthat_txt")
    unlink(output_directory, recursive = TRUE)
    dir.create(output_directory)
    for (file_name in list.files(full.names = TRUE, 
                                 system.file('tests', 'expected_files', 
                                             package = 'document'),
                                 pattern = "\\.txt"
                                 )
    ) {
        # create current
        options(useFancyQuotes = FALSE)
        input <- file.path(system.file('tests', 'files', package = 'document'), 
                           sub("\\.txt", ".R", basename(file_name)))
        print(file_name)
        print(input)
        txt_name <- document(input, output_directory = output_directory,
                             check = FALSE, runit = TRUE, clean = FALSE)[["txt_path"]]
        current <- readLines(txt_name)
        reference  <- readLines(file_name)
        expect_equal(current, reference)
    }
                 }
)
