running_on_my_machines <- function() {
    sys_info <- Sys.info()
    r <- sys_info[["nodename"]] %in% c("h7") && 
        sys_info[["effective_user"]] == "qwer" &&
        .Platform[["OS.type"]] == "unix"
    return(r)
}

set_NOT_CRAN  <- function() {
    is_unset <- is.na(Sys.getenv("NOT_CRAN", unset = NA))
    if (running_on_my_machines() && is_unset) 
        Sys.setenv("NOT_CRAN" = TRUE)
}

set_NOT_CRAN()
library("testthat")
library("document")
test_check("document")

