devtools::load_all()
options(useFancyQuotes = FALSE)
document(file_name = system.file("tests", "files", "simple.R", package = "document"), check_package = FALSE, runit = TRUE)
man("a_first_function")



