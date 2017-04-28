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

## ---- comment = ""-------------------------------------------------------
options(pager = switch(.Platform[["OS.type"]], "unix" = "cat", "console"))
document::man("foo")

