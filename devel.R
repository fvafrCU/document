devtools::load_all()
options(useFancyQuotes = FALSE)
document(file_name = system.file("tests", "files", "simple.R", package = "document"), check_package = FALSE, runit = TRUE)
man("a_first_function")

b = fake_package(file_name = system.file("tests", "files", "simple.R", package = "document"))
f = fake_package(file_name = system.file("tests", "files", "basic.R", package = "document"))
list.files(file.path(f, "man"), full.names = TRUE)
document(file_name = system.file("tests", "files", "basic.R", package = "document"), check_package = FALSE)
 document::display_Rd(list.files(file.path(get_dpd(), "man"), full.names = TRUE)[2])

devtools::load_all()
document::man(list.files(file.path(get_dpd(), "man"), full.names = TRUE)[2])
