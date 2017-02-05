#' Nothing Good For
#'
#' Just prints "foo!".
#' @author Your Name <you@@somewhe.re> 
#' @param x Not needed.
#' @return NULL
#' @examples
#' foo(x = 2)
foo <- function(x) {
    print("foo!")
    return(invisible(NULL))
}

print("foobar")

# ROXYGEN_START
#' Uhh
#'
#' Just prints "bar!".
#' @author Your Name <you@@somewhe.re> 
#' @return NULL
#' @examples
#' bar()
bar <- function() {
    print("bar!")
    return(invisible(NULL))
}
# ROXYGEN_STOP

print("bar")
