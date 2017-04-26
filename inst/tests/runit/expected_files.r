require("document")
test_txt <- function() {
    options(useFancyQuotes = FALSE)
    output_directory <- file.path(tempdir(), "document_runit_txt")
    unlink(output_directory, recursive = TRUE)
    dir.create(output_directory)
    for (file_name in list.files(full.names = TRUE,
                                 system.file("tests", "expected_files",
                                             package = "document"),
                                 pattern = "\\.txt"
                                 )
    ) {
        # create current
        input <- file.path(system.file("tests", "files", package = "document"),
                           sub("\\.txt", ".R", basename(file_name)))
        txt_name <- document(input, output_directory = output_directory,
                             check = FALSE, runit = TRUE)[["txt_path"]]
        current <- readLines(txt_name)
        reference  <- readLines(file_name)
        RUnit::checkTrue(identical(current, reference))
    }
}
