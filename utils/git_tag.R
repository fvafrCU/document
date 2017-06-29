# unexported from devtools
is_git_uncommitted <- function(path = ".") {
  r <- git2r::repository(path, discover = TRUE)
  status <- vapply(git2r::status(r), length, integer(1))
  return(any(status != 0))
}

is_git_clone <- function(path = ".") {
    is_git_clone <- ! is.null(git2r::discover_repository(path, ceiling = 0))
    return(is_git_clone)
}

git_tag <- function(path = ".") {
    status <- TRUE
    root <- tryCatch(rprojroot::find_root(rprojroot::is_r_package),
                     error = function(e) return(path))
    if (is_git_clone(root) && is_git_uncommitted(root))
        stop("Uncommited changes. Aborting")
    repo <- git2r::repository(root)
    tags <- git2r::tags(repo)
    last_tag_number <- slot(tags[[length(tags)]], "name")
    last_version_number <- sub("^v", "", last_tag_number)
    d <- readLines(file.path(root, "DESCRIPTION"))
    version <- sub("^Version: ", "", grep("^Version: ", d, value = TRUE))
    if (version != last_version_number)
         status <- system(paste("git tag -a", version))
    return(status)
}

