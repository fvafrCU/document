check_news <- function() {
    root <- rprojroot::find_root(rprojroot::is_r_package)
    description <- readLines(file.path(root, "DESCRIPTION"))
    version <- grep("^Version: ", description, value = TRUE)
    version_number <- trimws(strsplit(version, split = ":")[[1]][2])
    package <- grep("^Package: ", description, value = TRUE)
    package_name <- trimws(strsplit(package, split = ":")[[1]][2])
    news.md <- readLines(file.path(root, "NEWS.md"))
    devel_versions <- grep("[0-9]+\\.[0-9]+\\.[0-9]+\\.9000", news.md, 
                           value = TRUE)
    if (length(devel_versions) > 0) {
        devel_numbers <- sapply(devel_versions, function(x) strsplit(x, split = " ")[[1]][3])
        extra_devels <- setdiff(devel_numbers, version_number)
        if (length(extra_devels) > 0) {
            stop(paste("\nFound unmatched devel version: ", extra_devels)) 
        }
        
    }
    is_covered <- any(grepl(paste("^#", package_name, version_number), news.md)) 
    if (! is_covered) {
        stop("Version ", version_number, " not covered!")
    } else {
        return(TRUE)
    }

}
