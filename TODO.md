- make stop_on_check_not_passing multilevel:
c(NULL, "erros", "warnings", "notes", "never") and use an option to be read if
NULL (the default), then, if still NULL, set it to "warnings". Use the option in
testing by setting it to "errors".
in check_package use 
if (stop_on_check_not_passing == "never") condition <- FALSE
if (stop_on_check_not_passing %in% ("errors", "warnings", "notes") 
condition <- has_errors || has_warnings || has_notes 
....

- Think about devtools/R/R.r:
   #' Devtools sets a number of environmental variables to ensure consistent
   #' between the current R session and the new session, and to ensure that
   #' everything behaves the same across systems. It also suppresses a common
   #' warning on windows, and sets \code{NOT_CRAN} so you can tell that your
   #' code is not running on CRAN. If \code{NOT_CRAN} has been set externally, it
   #' is not overwritten.
   #'
   #' @keywords internal
   #' @return a named character vector
   #' @export
   Maybe this fixes the potential find.package-bug in check_package
