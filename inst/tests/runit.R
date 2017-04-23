#!/usr/bin/Rscript --vanilla
library('documentation')
library('RUnit')

.failure_details <- function(result) {
    message("This function is a verbatim copy of a part of the testPackage() function from:  
The Bioconductor Dev Team (). BiocGenerics: S4 generic functions for
Bioconductor. R package version 0.12.1.
It is copyright by The Bioconductor Dev Team (). ")
    res <- result[[1L]]
    if (res$nFail > 0 || res$nErr > 0) {
        Filter(function(x) length(x) > 0,
               lapply(res$sourceFileResults,
                      function(fileRes) {
                          names(Filter(function(x) x$kind != "success",
                                       fileRes))
                      }))
    } else list()
}
if (interactive()) setwd(dirname(tempdir()))
# create files
unit_dir <- system.file("tests", "runit", package = "documentation")
package_suite <- defineTestSuite('documentation_unit_test',
                                 dirs = unit_dir,
                                 testFileRegexp = '^.*\\.r',
                                 testFuncRegexp = '^test_+')

test_result <- runTestSuite(package_suite)
printTextProtocol(test_result, showDetails = TRUE)
html_file <- paste(package_suite$name, 'html', sep = '.')
printHTMLProtocol(test_result, fileName = html_file)
html <- file.path(getwd(), html_file)
file.copy(html, file.path(dirname(tempdir()), html_file), overwrite = TRUE)
if (interactive()) browseURL(paste0('file:', html))
if(length(.failure_details(test_result)) > 0) stop("RUnit failed.")
