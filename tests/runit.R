#!/usr/bin/Rscript --vanilla
is_failure <- function(result) {
    res <- result[[1]]
    names(res) <- tolower(names(res)) # soothe lintr
    sum_of_exceptions <- res[["nerr"]] + res[["nfail"]]
    fail <- as.logical(sum_of_exceptions)
    return(fail)
}
unit_dir <- system.file("runit", package = "document")
package_suite <- RUnit::defineTestSuite("document_unit_test",
                                        dirs = unit_dir,
                                        testFileRegexp = "^.*\\.r",
                                        testFuncRegexp = "^test_+")

test_result <- RUnit::runTestSuite(package_suite)
RUnit::printTextProtocol(test_result, showDetails = TRUE)
if (interactive()) {
    html_file <- paste(package_suite$name, "html", sep = ".")
    RUnit::printHTMLProtocol(test_result, fileName = html_file)
    html <- file.path(getwd(), html_file)
    browseURL(paste0("file:", html))
}
if (is_failure(test_result)) stop("RUnit failed.")
