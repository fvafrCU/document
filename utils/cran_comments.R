#!/usr/bin/Rscript --vanilla
# search for  $ Rscript -e 'sessionInfo()' in the raw log of the travis build
travis_copy <- c("
R version 3.4.1 (2017-06-30)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu precise (12.04.5 LTS)
")

provide_cran_comments <- function(comments_file = "cran-comments.md",
                                  check_log = "log/dev_check.Rout",
                                  travis_raw_log = travis_copy) {
    pkg <- devtools::as.package(".")
    check <- devtools:::parse_check_results(check_log)
    check_output <- capture.output(devtools:::print.check_results(check), 
                                   type = "message")[2]
    travis <- unlist(strsplit(travis_raw_log, "\n"))
    session <- suppressWarnings(sessionInfo())
    here <- c("",
              session$R.version$version.string,
              paste0("Platform: ", session$platform),
              paste0("Running under: ", session$running))

    comments <- c("Dear CRAN Team,\n", "this is a resubmission of package ", 
          pkg$package, ". I have added the following changes:\n", get_news(),
          "Please upload to CRAN.\n", "Best, Dominik\n")
    comments <- c(comments, c("\n# Package ", pkg$package," ", pkg$version, 
                      "\n## Test  environments ", "\n",
           "-", paste(here[here != ""], collapse = "\n  "), "\n", 
           "-", paste(travis[travis != ""], collapse = "\n  "), "\n", 
           "- win-builder (devel)", "\n", 
           "\n## R CMD check results\n", check_output,
           "\n"))
    if (file.exists(comments_file)) 
        writeLines(comments, con = comments_file, sep = "")
    return(invisible(comments))
}

get_news <- function(path = "."){
    root <- tryCatch(rprojroot::find_root(rprojroot::is_r_package, 
                                          path = path),
                     error = function(e) return(FALSE)
                     )
    if(root == FALSE) stop("Can't find the R package")
    description <- read.dcf(file.path(root, "DESCRIPTION"))
    news <- unlist(strsplit(paste(readLines("NEWS.md"), collapse = "\n"), split = "# "))
    package_pattern <- paste0("^", description[1, "Package"], " ", 
                            description[1, "Version"])
    news <- grep(package_pattern, news, value = TRUE) 
    news <- sub(paste0(package_pattern, "\n"), "", news)
    return(news)
}
