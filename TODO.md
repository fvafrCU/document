- make stop_on_check_not_passing multilevel:
c(NULL, "erros", "warnings", "notes", "never") and use an option to be read if
NULL (the default), then, if still NULL, set it to "warnings". Use the option in
testing by setting it to "errors".
in check_package use 
if (stop_on_check_not_passing == "never") condition <- FALSE
if (stop_on_check_not_passing %in% ("errors", "warnings", "notes") 
condition <- has_errors || has_warnings || has_notes 
....


- improve vignette
- make it pass testing on current windows (winbuilder, rhub)!
- get rid of empty .Rd2pdfxxx-dirs in testing. They might get created by devtools::load_all()
