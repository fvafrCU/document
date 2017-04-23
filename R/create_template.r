#' create a template for a roxygenizable file.
#'
#' a simple wrapper to copy a system file to the working directory.
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 38a4969351d9577aac18a25e178e6a734430dec4 $
#' @param  type The type of template to provide. Give the empty string ("") to
#' list available types.
#' @param  file_name  The name of the R code file to be created.
#' @return  See \code{\link{file.copy}}.
#' @examples 
#' create_template(file_name = "my_r_file.r", type = "roxygen_markdown")
create_template <- function(type = "template", file_name = ".") {
    qassert(type, "S1")
    qassert(file_name, "S1")
    available_types <- c("template", "standard", "roxygen", "markdown",
                             "roxygen_markdown", "rnw")
    if (! type  %in% available_types) stop(paste("type must be in c('", 
                                                 paste(available_types, 
                                                       collapse = "', '"
                                                       ),
                                                 "')",
                                                 sep = ""
                                                 )
    )
    if(type == "rnw") {
        template_name <- paste("documentation_", type, ".Rnw", sep = "")
    } else {
        template_name <- paste("documentation_", type, ".r", sep = "")
    }
    template_path <- file.path("templates", template_name)
    template_file <- system.file(template_path, package = "documentation")
    status <- file.copy(template_file, file_name)
    return(status)
}



