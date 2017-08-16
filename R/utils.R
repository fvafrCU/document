#' Sort a Character Vector in Lexical Order Avoiding the Locale
#'
#' \code{\link{sort}} uses the collation of the locale (see
#' \code{\link{Comparison}}), which results in different sorting. If a
#' (\pkg{RUnit})
#' check relies on sorting, we need to avoid the locale.
#'
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

#' Alter Contents of a DESCRIPTION File
#'
#' Substitutes and/or adds fields in a DESCRIPTION file.
#'
#' @param path Path to the DESCRIPTION file or the directory containing it.
#' @param substitution A list of named character vector giving the pairs for
#' substitution. 
#' @param addition A list of named character vector giving the pairs for
#' addition 
#' @return value of \code{\link{write.dcf}}.
#' @export
alter_description_file <- function(path, substitution = NULL, addition = NULL) {
    status  <- 0
    if (is.list(substitution)) substitution <- unlist(substitution)
    if (is.list(addition)) addition <- unlist(addition)
    if (basename(path) != "DESCRIPTION") path <- file.path(path, "DESCRIPTION")
    d <- read.dcf(path)
    for (x in names(substitution)) {
        d[1, x] <- substitution[[x]]
    }
    if (! is.null(addition)) d <- cbind(d, as.matrix(t(addition)))
    status <- write.dcf(d, path)
    return(status)
}

#' Make a Default DESCRIPTION File Pass \command{R CMD check}
#'
#' \code{utils::\link[utils]{package.skeleton}} leaves us with a DESCRIPTION 
#' that throws a warning in \command{R CMD check}. Fix that. 
#' @inheritParams alter_description_file
#' @return value of \code{\link{alter_description_file}}.
#' @export
#' @examples
#' utils::package.skeleton(path = tempdir())
#' old <- readLines(file.path(tempdir(), "anRpackage", "DESCRIPTION"))
#' clean_description_file(path = file.path(tempdir(), "anRpackage", 
#'                                         "DESCRIPTION"))
#' new <- readLines(file.path(tempdir(), "anRpackage", "DESCRIPTION"))
#' setdiff(new, old)
clean_description_file <- function(path) {
    s <- list(Version = "1.0.0",
              License = "GPL",
              Title = "A FAke Title",
              Description = "This is just a fake package description.")
    status <- alter_description_file(path = path, substitution = s)
    return(invisible(status))
}

#' Clean a String Created From a Run Through \pkg{RUnit}
#'
#' Why am I doing this? It want to run \pkg{RUnit} tests from within 
#' \command{R CMD check}
#' check and interactively.
#' Files produced are compared with expected files. 
#' Now \command{R CMD check} and interactive (and batch) runs of \pkg{RUnit}
#' give different encodings.
#' I don't know why, but they do. And this is a rather lousy fix. See the code
#' for details.
#'
#' @param txt A character vector.
#' @return The sanitized character vector.
Rd_txt_RUnit <- function(txt) {
    # TODO: this is dreadful, I'm converting non-ascii to byte and that back to
    # ascii again, but
    # - setting the options(useFancyQuotes = 'UTF-8') and
    # - gsub("\u0060", "'", Rd_txt) (I thought u0060 would be the backtick)
    # didn't seem to help.
    # After \command{R CMD check} the XXX.Rcheck/tests/startup.R
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
