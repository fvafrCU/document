devtools::load_all()
file_name  <- file.path(system.file("tests",
                                    "files",
                                    package = "document"),
                        "warn.R")
res <- document(file_name, check_package = TRUE, runit = TRUE, debug = TRUE)
