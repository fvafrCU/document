grep_directory <- function(path, pattern, exclude = NULL) {
    hits <- NULL
    files <- list.files(path, full.names = TRUE, recursive = TRUE)
    if (! is.null(exclude))
        files <- grep(exclude, files, value = TRUE, invert = TRUE)
    for (f in files) {
        l <- readLines(f)
        if (any(grepl(l, pattern = pattern, perl = TRUE))) {
            found <- paste(f, sep = ": ",
                         grep(l, pattern = pattern, perl = TRUE, value = TRUE))
            hits <- c(hits, found)
        }
    }
    return(hits)
}

check_codetags <- function(path = ".", exclude = ".*\\.tar\\.gz$") {
    return(grep_directory(path = path, exclude = exclude, pattern =  "XXX:|FIXME:|TODO:"))
}

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
