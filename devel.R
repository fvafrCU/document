devtools::load_all()
#built_path <- devtools::build()
#callr::rcmd_safe("Rd2pdf", ".")
#callr::rcmd_safe("build", ".")


file_name = file.path("inst", "test", "files", "documentation_roxygen.r")
output_directory = "/tmp/bar"
check_package = TRUE
clean = FALSE
working_directory = tempfile()
dependencies = NULL
#% define variables
out_file_name <- sub(".Rnw$", ".r", basename(file_name))
package_name <- gsub("_", ".",
                     sub(".[rRS]$|.Rnw$", "", out_file_name, perl = TRUE)
                     )
package_directory <- file.path(working_directory, package_name)
man_directory <- file.path(package_directory, "man")
pdf_name <- sub("[rRS]$", "pdf", out_file_name)
pdf_path <- file.path(output_directory, pdf_name)
txt_name <- sub("[rRS]$", "txt", out_file_name)
txt_path <- file.path(output_directory, txt_name)
# out_file_name may contain underscores, which need to be escaped for LaTeX.
file_name_tex <- gsub("_", "\\_", out_file_name, fixed = TRUE)
pdf_title <- paste("'Roxygen documentation for file", file_name_tex, "\'")
if (.Platform$OS.type != "unix") { 
    ## on windows, R CMD Rd2pdf crashes with multi-word titles... I have no
    ## clue of the why.
    pdf_title <- file_name_tex
    ## man dir on windows must be in slashes... at least for R CMD Rd2pdf,
    ## again, I have no clue.
    man_directory <- sub("\\\\","/", man_directory)
}
dir.create(working_directory)
if (isTRUE(clean)) on.exit(unlink(working_directory, recursive = TRUE), add =TRUE)
if (! dir.exists(output_directory)) dir.create(output_directory)

roxygen_code <- get_lines_between_tags(file_name) # XXX:, ...)
if (is.null(roxygen_code) || ! any(grepl("^#+'", roxygen_code))) {
    stop(paste("Couldn't find roxygen comments in file", file_name,
               "\n You shoud set from_firstline and to_lastline to FALSE."))
}
#% write new file to disk
writeLines(roxygen_code, con = file.path(working_directory, out_file_name))
#% create a package from new file
package.skeleton(code_files = file.path(working_directory, out_file_name),
                 name = package_name, path = working_directory,
                 force = TRUE)
#% create documentation from roxygen comments for the package
roxygen2::roxygenize(package.dir = package_directory)
fix_package_documentation(package_directory)
add_dependencies_to_description(package_directory, dependencies)
callr::rcmd_safe("Rd2pdf", c("--no-preview --internals --force", paste0("--title=", pdf_title),  paste0("--output=", pdf_path), man_directory))
# using R CMD Rdconv on the system instead of Rd2txt since ?Rd2txt states
# it's "mainly intended for internal use" and its interface is "subject to
# change."
Rd_txt <- NULL
files  <- sort_unlocale(list.files(man_directory, full.names = TRUE))
for (rd_file in files) {
    Rd_txt <- c(Rd_txt, callr::rcmd_safe("Rdconv", c("--type=txt", rd_file))[["stdout"]])
}
# TODO: this is dreadful, I'm converting non-ascii to byte and that back to
# ascii again, but 
# - setting the options(useFancyQuotes = 'UTF-8') and 
# - gsub("\u0060", "'", Rd_txt) (I thought u0060 would be the backtick)
# didn't seem to help. 
# Why am I doing this? It want to run RUnit tests from within R CMD check
# and interactively. Files produced are compared with expected files. Now R
# CMD check and interactive (and batch) give different encodings. I don't
# know why, but they do. 
# After R CMD check the XXX.Rcheck/tests/startup.R reads:
# options(useFancyQuotes = FALSE)
# Have I tried that yet?
Rd_txt <- gsub("<e2><80><99>" ,"'", 
               gsub("<e2><80><98>", "'", 
                    iconv(Rd_txt, to = "ASCII", mark = TRUE, sub = "byte")
                    )
               )
writeLines(iconv(Rd_txt, to = "ASCII", mark = TRUE), con = txt_path)
if (check_package) {
    check <- devtools::check(package_directory)
}

