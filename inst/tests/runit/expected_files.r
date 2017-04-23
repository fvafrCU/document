require("RUnit")
require("document")
test_txt <- function() {
    output_directory <- file.path(dirname(tempdir()), "documentation_test_txt")
    unlink(output_directory, recursive = TRUE)
    dir.create(output_directory)
    for (file_name in list.files(full.names = TRUE, 
                                 system.file('tests', 'expected_files', 
                                             package = 'document'),
                                 pattern = "\\.txt"
                                 )
    ) {
        # create current

        current <- readLines(txt_name)
        reference  <- readLines(file_name)
        # delete lines containing differing git Id tags
        current <- grep("*\\$Id:*", current, invert = TRUE, value = TRUE)
        reference <- grep("*\\$Id:*", reference, invert = TRUE, value = TRUE)
        checkTrue(identical(current, reference))
    }
}
