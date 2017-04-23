devtools::load_all()

file_name = file.path("inst", "tests", "files", "documentation_roxygen.r")
document(file_name = file_name)
