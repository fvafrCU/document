path <- system.file("tests", "files", "minimal.R", package = "document")
cat(readLines(path), sep = "\n")
d <- document::document(file_name = path, check_package = FALSE)
cat(readLines(d[["txt_path"]]), sep = "\n")
project_root <- rprojroot::find_root(rprojroot::is_r_package)
d <- document::document(file_name = path,
                        output_directory = file.path(project_root,
                                                     "inst", "tests", "files"),
                        check_package = FALSE)
file.remove(unlist(d[c("txt_path", "pdf_path")]))
## res <- document(file_name = system.file("tests", "files", "minimal.R",
##                                         package = "document"),
##                 check_package = TRUE)
## cat(res[["check_result"]][["stdout"]], sep = "\n")
## cat(res[["check_result"]][["stderr"]], sep = "\n")
path <- system.file("tests", "files", "simple.R", package = "document")
cat(readLines(path), sep = "\n")
d <- document::document(file_name = path, check_package = FALSE)
cat(readLines(d[["txt_path"]]), sep = "\n")
# owing to Dason Kurkiewicz <dasonk@gmail.com>, 
# https://github.com/Dasonk/docstring
options(help_type = "text")

# A pager that outputs to the console
console_pager <- function(x, ...){
    input <- readLines(x)
    # Had some issues with _ getting displayed
    # in the output console output which
    # messed up rendering in the created html vignette
    # So remove that before outputting.
    input <- gsub("_", "", input)
    cat(paste(input, collapse = "\n"), "\n")
}
options(pager = console_pager)
path <- system.file("tests", "files", "minimal.R", package = "document")
document::man(x = path, topic = "foo")
