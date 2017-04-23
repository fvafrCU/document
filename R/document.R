#' roxygenize an R code file, output the documentation to pdf.
#'
#' @author Dominik Cullmann, <dominik.cullmann@@forst.bwl.de>
#' @section Version: $Id: 9bbb752b06d887f2115e37c3e9dadd89e40c49c7 $
#' @param file_name  The name of the R code file to be documented.
#' @param output_directory The directory to put the documentation into.
#' @param overwrite Overwrite an existing documentation file?
#' @param check_package Run R CMD check on the sources?
#' @param dependencies a character vector of package names the functions depend
#' on.
#' @param copy_tmp_files_to path to copy temporary files to. See Note. \cr This
#' parameter has no effect if make_check is not TRUE.
#' @param working_directory A working directory. Defaults to tempdir().
#' \bold{Warning} the working_directory will be recursively
#' \code{\link{unlink}}ed. You can erase your disk if you change the default!
#' @param ... Arguments passed to \code{\link{get_lines_between_tags}}.
#' @return TRUE if pdf creation is successfull, FALSE otherwise.
#' @examples
#' create_template(file_name = "my_r_file.r", type = "template")
#' create_roxygen_documentation("my_r_file.r", overwrite = TRUE)
create_roxygen_documentation <- function(
                                         file_name,
                                         output_directory = ".",
                                         overwrite = FALSE,
                                         check_package = TRUE,
                                         copy_tmp_files_to = dirname(tempdir()),
                                         working_directory = tempdir(),
                                         dependencies = NULL,
                                         ...
                                         ) {
    checkmate::assertFile(file_name, access = "r")
    checkmate::assertDirectory(output_directory, access = "r")
    checkmate::qassert(overwrite, "B1")
    checkmate::qassert(check_package, "B1")
    checkmate::assertDirectory(copy_tmp_files_to, access = "r")
    checkmate::assertCharacter(dependencies, null.ok = TRUE)
    checkmate::qassert(working_directory, "S1")
    return(invisible())
}
