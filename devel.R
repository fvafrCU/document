devtools::load_all()
path <- system.file("tests", "files", "minimal.R", package = "document")
document::man(x = path, topic = "foo")
options(useFancyQuotes = FALSE)
document(file_name = system.file("tests", "files", "simple.R", package = "document"), check_package = FALSE, runit = TRUE)
x = document(file_name = system.file("tests", "files", "simple.R", package = "document"), check_package = TRUE, runit = TRUE)
y = document(file_name = system.file("tests", "files", "warn.R", package = "document"), check_package = TRUE, runit = TRUE)
z = document(file_name = system.file("tests", "files", "err.R", package = "document"), check_package = TRUE, runit = TRUE)
man("a_first_function")

b = fake_package(file_name = system.file("tests", "files", "simple.R", package = "document"))
f = fake_package(file_name = system.file("tests", "files", "minimal.R", package = "document"))
list.files(file.path(f, "man"), full.names = TRUE)
document(file_name = system.file("tests", "files", "minimal.R", package = "document"), check_package = FALSE)
 document::display_Rd(list.files(file.path(get_dpd(), "man"), full.names = TRUE)[2])

devtools::load_all()
document::man(list.files(file.path(get_dpd(), "man"), full.names = TRUE)[2])
man(list.files(file.path(get_dpd(), "man"), full.names = TRUE)[2])



res <- document(file_name = system.file("tests", "files", "minimal.R", 
                                        package = "document"), 
                check_package = TRUE)

# View R CMD check results.
cat(res[["check_result"]][["stdout"]], sep = "\n")
cat(res[["check_result"]][["stderr"]], sep = "\n")

# Copy docmentation to current working directory.
# This writes to your disk. So it's disabled. 
# Remove or comment out the next line to enable.
if (FALSE) 
    file.copy(res[["pdf_path"]], getwd())

library(profvis)
profvis({
res <- document(file_name = system.file("tests", "files", "minimal.R", 
                                        package = "document"), 
                check_package = TRUE)
})

working_directory = "/tmp"
package_directory = "."
tgz <- "document_1.2.1.9000.tar.gz"
    tmp <- callr::rcmd_safe("check",
                        c(paste0("--output=", working_directory), tgz))

d <- document("R/document.R", stop_on_check_not_passing = FALSE)
