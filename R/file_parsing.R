#' Cut Code Chunks From a File
#'
#' Get all lines between tagged lines. The tagged lines themselves may be in- or
#' excluded from the selection.
#'
#' @param file_name  The name of the R code file to be parsed.
#' @param keep_tagged_lines Keep tagged lines output?
#' @param end_pattern  A pattern that marks the line ending a \pkg{roxygen2}
#' chunk.
#' @param begin_pattern  A pattern that marks the line beginning a
#' \pkg{roxygen2}
#' chunk.
#' @param from_first_line Use first line as tagged line if first tag found
#' matches the \code{end_pattern}?
#' @param to_last_line Use last line as tagged line if last tag found matches
#' the \code{begin_pattern}?
#' @note If you know the file to contain valid \pkg{roxygen2} code only, you do
#' not
#' need to tag any lines if you keep from_first_line and to_last_line both TRUE:
#' in this case the whole file will be returned.
#' @return A character vector of matching lines.
get_lines_between_tags <- function(file_name, keep_tagged_lines = TRUE,
                         begin_pattern = "ROXYGEN_START",
                         end_pattern = "ROXYGEN_STOP",
                         from_first_line = TRUE,
                         to_last_line = TRUE
                         ) {
    checkmate::assertFile(file_name, access = "r")
    checkmate::qassert(begin_pattern, "S1")
    checkmate::qassert(end_pattern, "S1")
    checkmate::qassert(keep_tagged_lines, "B1")
    checkmate::qassert(from_first_line, "B1")
    checkmate::qassert(to_last_line, "B1")
    R_code_lines <- readLines(file_name)
    found_begin_tag <- any(grepl(begin_pattern, R_code_lines))
    found_end_tag <- any(grepl(end_pattern, R_code_lines))
    if (found_begin_tag || found_end_tag) {
        if (! found_begin_tag)
            begin_line_indices <- 1
        else
            begin_line_indices <- grep(begin_pattern, R_code_lines)
        if (! found_end_tag)
            end_line_indices <- 1
        else
            end_line_indices <- grep(end_pattern, R_code_lines)
        if (from_first_line)
            if (begin_line_indices[1] > end_line_indices[1])
                begin_line_indices  <- c(1, begin_line_indices)
        if (to_last_line)
            if (end_line_indices[1] < begin_line_indices[1])
                end_line_indices  <- c(end_line_indices, length(R_code_lines))
    } else {
        if (from_first_line && to_last_line) {
            begin_line_indices <- 1
            end_line_indices <- length(R_code_lines)
        } else {
            return(NULL)
        }
    }
    if (length(begin_line_indices) != length(end_line_indices))
        stop("found unequal number of begin and end tags")
    if (length(begin_line_indices) != length(end_line_indices))
        stop("found unequal number of begin and end tags")
    if (! all(begin_line_indices <= end_line_indices))
        stop("begin and end tags not in proper order")
    t <- paste("R_code_lines[c(", paste(paste(begin_line_indices,
                                        end_line_indices, sep = ":"),
                        collapse = ","), ")]")
    selected_lines <- eval(parse(text = t))
        if (! keep_tagged_lines) {
            pattern_lines <- grep(paste0(begin_pattern, "|", end_pattern),
                                  selected_lines)
            selected_lines <- selected_lines[- pattern_lines]
        }
    return(selected_lines)
}
