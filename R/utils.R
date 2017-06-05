#' Sort a Character Vector in Lexical Order Avoiding the Locale
#'
#' \code{\link{sort}} uses the collation of the locale (see
#' \code{\link{Comparison}}), which results in different sorting. If a (RUnit)
#' check relies on sorting, we need to avoid the locale.
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
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

#' Change License in the DESCRIPTION File to "GPL"
#'
#' utils::package.skeleton() leaves us with a DESCRIPTION that throws a warning
#' in R CMD check. Fix that.
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
# TODO: nasty hardcoding
#' @note We also set Version to 0.0-0, hoping nobody is going to use
#' that.
#' @param package_directory Path to the directory.
#' @return value of \code{link{writeLines}}.
clean_description <- function(package_directory) {
    description_file <- file.path(package_directory, "DESCRIPTION")
    description <-  readLines(description_file)
    description <-  sub("(Version: ).*", "\\11.0.0", description)
    description <-  sub("(License: ).*", "\\1GPL", description)
    description <-  sub("(Title: ).*", "\\1Fake a Title", description)
    description <-  sub("(Description: .*)", "\\1\\.", description)
    status <- writeLines(description, con = description_file)
    return(invisible(status))
}

#' Add a "Depends:"-field to the DESCRIPTION File
#'
#' if the functions in the temporary package depend on other functions (from,
#' for example, the checkmate package), you can add the whole package as a
#' dependency.
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @param package_directory Path to the directory.
#' @param dependencies the package names the temporary package will depend on.
#' @return value of \code{link{writeLines}}.
add_dependencies_to_description <- function(package_directory,
                                            dependencies = NULL) {
    # TODO: dependencies should be a named list possibly containing dependencies
    # and imports and then alter the DESCRIPTION's lines accordingly
    description_file <- file.path(package_directory, "DESCRIPTION")
    description <-  readLines(description_file)
    if (! is.null(dependencies))
        description <- c(description, paste0("Depends: ",
                                             paste(dependencies,
                                                   collapse = ", ")))
    status <- writeLines(description, con = description_file)
    return(invisible(status))
}


Rd_txt_RUnit <- function(txt) {
#' clean a string created from a run through RUnit
#'
#' Why am I doing this? It want to run RUnit tests from within R CMD check
#' and interactively. Files produced are compared with expected files. Now R
#' CMD check and interactive (and batch) give different encodings. I don't
#' know why, but they do.
#'
#' @author Andreas Dominik Cullmann, <adc-r@@arcor.de>
#' @param txt a character vector
#' @return the sanitized character vector
    # TODO: this is dreadful, I'm converting non-ascii to byte and that back to
    # ascii again, but
    # - setting the options(useFancyQuotes = 'UTF-8') and
    # - gsub("\u0060", "'", Rd_txt) (I thought u0060 would be the backtick)
    # didn't seem to help.
    # After R CMD check the XXX.Rcheck/tests/startup.R
    # reads: options(useFancyQuotes = FALSE) # Exclude Linting
    # Have I tried that yet?
    new_txt <- gsub("<e2><80><99>", "'",
                    gsub("<e2><80><98>", "'",
                         iconv(txt, to = "ASCII", mark = TRUE, sub = "byte")
                         )
                    )
    new_txt <- iconv(new_txt, to = "ASCII", mark = TRUE)
    return(new_txt)
}
