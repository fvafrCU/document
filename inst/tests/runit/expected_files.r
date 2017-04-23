require("RUnit")
require("documentation")
test_md <- function() {
    for (file_name in list.files(full.names = TRUE, 
                                 system.file('tests', 'expected_files', 
                                             package = 'documentation'),
                                 pattern = "\\.md"
                                 )
    ) {

        type <- sub("\\.r_markdown.md", "", sub("documentation_", "",
                                                basename(file_name)))
        type <- sub("\\.Rnw_markdown.md", "", type)
        name <- paste0(type, ".r")
        create_template(type = type, file_name = name)
        create_markdown_documentation(name)
        current <- readLines(paste0(name, "_markdown.md"))
        reference  <- readLines(file_name)
        # delete lines containing differing git Id tags
        current <- grep("*\\$Id:*", current, invert = TRUE, value = TRUE)
        reference <- grep("*\\$Id:*", reference, invert = TRUE, value = TRUE)
        checkTrue(identical(current, reference))
    }
}
test_txt <- function() {
    output_directory <- file.path(dirname(tempdir()), "documentation_test_txt")
    unlink(output_directory, recursive = TRUE)
    dir.create(output_directory)
    for (file_name in list.files(full.names = TRUE, 
                                 system.file('tests', 'expected_files', 
                                             package = 'documentation'),
                                 pattern = "\\.txt"
                                 )
    ) {
        type <- sub("\\.txt", "", sub("documentation_", "",
                                      basename(file_name)))
        type <- sub("\\.Rnw_markdown.md", "", type)
        r_name <- paste0("documentation_", type, ".r")
        txt_name <- sub("\\.r", "\\.txt", r_name)
        create_template(type = type, file_name = r_name)
        create_roxygen_documentation(r_name, 
                                     working_directory = file.path(dirname(tempdir()), "documentation_work"),
                                     output_directory = output_directory,
                                     check_package = FALSE
                                     )
        current <- readLines(txt_name)
        reference  <- readLines(file_name)
        # delete lines containing differing git Id tags
        current <- grep("*\\$Id:*", current, invert = TRUE, value = TRUE)
        reference <- grep("*\\$Id:*", reference, invert = TRUE, value = TRUE)
        checkTrue(identical(current, reference))
    }
}
