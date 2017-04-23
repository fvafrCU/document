#' provide required packages
#'
#' install packages as required, then load all required packages.
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: ab696f28eb22651bc1bfc8772d53d777927e82db $
#' @param packages  a vector of names of the required packages.
#' @param mirror the repository mirror to be used for installation of missing
#' packages.
#' @return TRUE if all required packages were succesfully loaded, FALSE
#' otherwise.
provide_packages <- function(packages,
                             mirror = "http://ftp5.gwdg.de/pub/misc/cran/") {
    status = NULL
    missing_packages <- get_missing_packages(packages)
    is_installation_required <- as.logical(length(missing_packages))
    if(is_installation_required) {
        utils::install.packages(missing_packages, repos = mirror)
    }
    for (package in packages) {
        tmp <- library(package, character.only = TRUE,  logical.return = TRUE)
        status <- c(status, tmp)
    }
    return(invisible(all(status)))  
}

#' check which of the required packages are not installed on the system
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: ab696f28eb22651bc1bfc8772d53d777927e82db $
#' @param required_packages  a vector of names of the required packages.
#' @return a vector of names of the missing packages.
get_missing_packages <- function(required_packages) {
    installed_packages <- rownames(utils::installed.packages())
    is_required_and_installed <- required_packages  %in% installed_packages
    missing_packages <- required_packages[which(! is_required_and_installed)]
    return(missing_packages)
}

#' test if pandoc is installed on the system
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: ab696f28eb22651bc1bfc8772d53d777927e82db $
#' @return TRUE if pandoc is installed, FALSE otherwise
is_pandoc_installed <- function() {
    return(as.logical(length(Sys.which("pandoc"))))
}

#' install pandoc
#'
#' pandoc is provided via installr::install.pandoc
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: ab696f28eb22651bc1bfc8772d53d777927e82db $
#' @return TODO
install_pandoc <- function() {
    switch(.Platform$OS.type,
           "windows" = {
               provide_packages("installr")
               installr::install.pandoc()
           }
           , stop(paste("this is intended for windows, not for ",
                        .Platform$OS.type, ". Use your package/ports manager ",
                        "or compile pandoc from source.", sep = ""
                        )
           )              
       )
    return(invisible())
}

#' install pandoc if not already installed on the system
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: ab696f28eb22651bc1bfc8772d53d777927e82db $
#' @return TODO
provide_pandoc <- function() {
    if (! is_pandoc_installed()) install_pandoc()
    return(invisible())
}
