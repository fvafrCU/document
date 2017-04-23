#' sort a character vector in lexical order avoiding the locale.
#'
#' \code{\link{sort}} uses the collation of the locale (see
#' \code{\link{Comparison}}), which results in different sortings. If a (RUnit)
#' check relies on sorting, we need to avoid the locale.
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 3d72fa8d41ea4e2e7b29ffdfefc45e58fe5274b5 $
#' @param char The character vector to sort.
#' @return The sorted character vector.
sort_unlocale <- function(char) {
    char0 <- char
    for (letter in letters) {
        char0 <-  gsub(paste0(toupper(letter)), 
                         paste0(which(letter == letters) * 10, "_"),
                         char0)
        char0 <-  gsub(paste0(letter), 
                         paste0(which(letter == letters) * 10 + 1, "_"),
                         char0)
    }
    return(char[order(char0)])
}

#' Remove autogenerated package Rd from man directory
#'
#' utils::package.skeleton() and roxygen2::roxygenize() leave us with an invalid
#' PACKAGENAME-package.Rd file in the man directory. It needs to be removed.
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 3d72fa8d41ea4e2e7b29ffdfefc45e58fe5274b5 $
#' @param package_directory Path to the directory.
#' @return value of \code{link{base::file.remove()}}.
remove_package_Rd <- function(package_directory) {
    package_name <- basename(package_directory)
    package_rd <- paste(package_name, "-package.Rd", sep = "")
    status <- file.remove(file.path(package_directory, "man", package_rd))
    return(invisible(status))
}

#' Change License in the DESCRIPTION file to "GPL"
#'
#' utils::package.skeleton() leaves us with a DESCRIPTION that throws a warning 
#' in R CMD check. Fix that.
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 3d72fa8d41ea4e2e7b29ffdfefc45e58fe5274b5 $
# TODO: nasty hardcoding
#' @note We also set Version to 0.0-0, hoping nobody is going to use
#' that.
#' @param package_directory Path to the directory.
#' @return value of \code{link{writeLines}}.
clean_description <- function(package_directory) {
    description_file <- file.path(package_directory, "DESCRIPTION") 
    description <-  readLines(description_file)
    description <-  sub("(License: ).*", "\\1GPL", description)
    # TODO: nasty hardcoding
    description <-  sub("(Version: ).*", "\\10.0-0", description) 
    description <-  sub("(Description: .*)", "\\1\\.", description) 
    status <- writeLines(description, con = description_file)
    return(invisible(status))
}

#' Add a "Depends:"-field to the DESCRIPTION file
#'
#' if the functions in the temporary package depend on other functions (from,
#' for example, the checkmate package), you can add the whole package as a
#' dependency.
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 3d72fa8d41ea4e2e7b29ffdfefc45e58fe5274b5 $
#' @param package_directory Path to the directory.
#' @param dependencies the package names the temporary package will depend on.
#' @return value of \code{link{writeLines}}.
add_dependencies_to_description <- function(package_directory, 
                                            dependencies = NULL) {
    description_file <- file.path(package_directory, "DESCRIPTION") 
    description <-  readLines(description_file)
    if (! is.null(dependencies))
        description <- c(description, paste0("Depends: ", 
                                             paste(dependencies, 
                                                   collapse = ", ")))
    status <- writeLines(description, con = description_file)
    return(invisible(status))
}
#' fix a \code{\link{package.skeleton}}s package skeleton. 
#'
#' This is just a conviniece wrapper to \code{\link{remove_package_Rd}} and
#' \code{\link{clean_description}}.
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 3d72fa8d41ea4e2e7b29ffdfefc45e58fe5274b5 $
#' @param package_directory Path to the directory.
#' @return invisibly NULL.
fix_package_documentation <- function(package_directory) {
    remove_package_Rd(package_directory)
    clean_description(package_directory)
    return(invisible(NULL))
}

#' build and check a temporary package intended for documentation mainly.
#'
#' We might want to see if the temporary package we've created to document our
#' code file would build and pass R CMD check as a proper package.
#' 
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 3d72fa8d41ea4e2e7b29ffdfefc45e58fe5274b5 $
#' @param package_directory Path to the packages' directory.
#' @param copy_tmp_files_to Path to save output from R CMD check to.
#' @return invisibly 0, if R CMD check returned 0, nothing otherwise.
build_and_check_package <- function(package_directory, 
                                    copy_tmp_files_to = dirname(tempdir())) {
    assertDirectory(copy_tmp_files_to, access = "r")
    assertDirectory(package_directory, access = "r")
    # TODO: R CMD build overwrites existing files!
    # Workaround: The tarball created will have name tar_ball, see below.
    system(paste("R --vanilla CMD build", package_directory))
    package_name <- basename(package_directory)
    # The name derives from clean_description(), see its NOTE.
    tar_ball <- paste0(package_name, "_0.0-0.tar.gz")
    on.exit(unlink(tar_ball))
    r_cmd_check_status <- system(paste0("R --vanilla CMD check ", tar_ball, 
                                        " --output=", copy_tmp_files_to))
    if(r_cmd_check_status != 0) {
        stop(paste0("R CMD check failed for package ", package_name, 
                    ", R CMD check ouput is in ", copy_tmp_files_to, "."))
    }
    return(invisible(r_cmd_check_status))
}


