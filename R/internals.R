#' Throw an Error
#'
#' Throws a condition of class c("document", "error", "condition").
#'
#' We use this condition as an error dedicated to \pkg{document}.
#'
#' @param message_string The message to be thrown.
#' @param system_call The call to be thrown.
#' @param ... Arguments to be passed to \code{\link{structure}}.
#' @return FALSE. But it does not return anything, it stops with a
#' condition of class c("document", "error", "condition").
#' @keywords internal
#' @examples
#' tryCatch(document:::throw("Hello error!"), error = function(e) return(e))
throw <- function(message_string, system_call = sys.call(-1), ...) {
    checkmate::qassert(message_string, "s*")
    condition <- structure(
                           class = c("document", "error", "condition"),
                           list(message = message_string, call = system_call),
                           ...
                           )
    stop(condition)
    return(FALSE)
}

#' Throw a Warning
#'
#' Throws a condition of class c("document", "warning", "condition").
#'
#' We use this condition as a warning dedicated to \pkg{document}.
#'
#' @param message_string The message to be thrown.
#' @param system_call The call to be thrown.
#' @param ... Arguments to be passed to \code{\link{structure}}.
#' @return The condition.
#' @keywords internal
#' @examples
#' tryCatch(document:::warn("Hello error!"), error = function(e) return(e))
warn <- function(message_string, system_call = sys.call(-1), ...) {
    checkmate::qassert(message_string, "s*")
    condition <- structure(
                           class = c("document", "warning", "condition"),
                           list(message = message_string, call = system_call),
                           ...
                           )
    warning(condition)
    return(condition)
}
