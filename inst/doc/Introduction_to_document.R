## ---- comment = ""-------------------------------------------------------
path <- system.file("tests", "files", "minimal.R", package = "document")
cat(readLines(path), sep = "\n")

## ---- result = "hide", message = FALSE-----------------------------------
d <- document::document(file_name = path, check_package = FALSE)

## ---- comment = ""-------------------------------------------------------
cat(readLines(d[["txt_path"]]), sep = "\n")

## ---- echo = FALSE, results = "hide", message = FALSE--------------------
d <- document::document(file_name = path, 
                        output_directory = file.path(rprojroot::find_root(rprojroot::is_r_package), 
                                                     "inst", "tests", "files"),
                        check_package = FALSE)
file.remove(unlist(d[c("txt_path", "pdf_path")]))

## ---- eval = FALSE-------------------------------------------------------
#  res <- document(file_name = system.file("tests", "files", "minimal.R",
#                                          package = "document"),
#                  check_package = TRUE)

## ---- eval = FALSE-------------------------------------------------------
#  cat(res[["check_result"]][["stdout"]], sep = "\n")
#  cat(res[["check_result"]][["stderr"]], sep = "\n")

## ---- comment = ""-------------------------------------------------------
path <- system.file("tests", "files", "simple.R", package = "document")
cat(readLines(path), sep = "\n")

## ---- result = "hide", message = FALSE-----------------------------------
d <- document::document(file_name = path, check_package = FALSE)

## ---- comment = ""-------------------------------------------------------
cat(readLines(d[["txt_path"]]), sep = "\n")

## ---- echo = FALSE-------------------------------------------------------
# owing to Dason Kurkiewicz <dasonk@gmail.com>, https://github.com/Dasonk/docstring
options(help_type="text")

# A pager that outputs to the console
console_pager <- function(x, ...){
    input <- readLines(x)
    # Had some issues with _ getting displayed
    # in the output console output which
    # messed up rendering in the created html vignette
    # So remove that before outputting.
    input <- gsub("_", "", input)
    cat(paste(input,collapse="\n"), "\n")}
options(pager=console_pager)

## ---- comment = "", message = FALSE, warning = FALSE---------------------
path <- system.file("tests", "files", "minimal.R", package = "document")
document::man(x = path, topic = "foo")

