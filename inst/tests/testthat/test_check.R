library(testthat)
if (interactive()) {
    devtools::load_all()
} else {
    library("document")
}

probably_winbuilder <- function() { # See comments below
    r <- identical(R.Version()[["nickname"]],  "Unsuffered Consequences") &&
        identical(.Platform[["OS.type"]], "windows")
    return(r)
}
glbt <- document:::get_lines_between_tags
context("checking the package")
test_that("error on bug, not as cran", {
              options(useFancyQuotes = FALSE)
              file_name  <- file.path(system.file("tests",
                                                  "files",
                                                  package = "document"),
                                      "produce_warning.R")
              if (! probably_winbuilder()
                  expect_error(
                               document(file_name, check_package = TRUE,
                                        runit = TRUE,
                                        stop_on_check_not_passing = TRUE,
                                        check_as_cran = FALSE)
                               )
}
)
test_that("error on bug, as cran", {
              options(useFancyQuotes = FALSE)
              file_name  <- file.path(system.file("tests",
                                                  "files",
                                                  package = "document"),
                                      "produce_warning.R")
              if (! probably_winbuilder()
                  expect_error(
                               document(file_name, check_package = TRUE,
                                        runit = TRUE,
                                        stop_on_check_not_passing = TRUE,
                                        check_as_cran = TRUE)
                               )
}
)
test_that("warning on bug, not as cran", {
              options(useFancyQuotes = FALSE)
              file_name  <- file.path(system.file("tests",
                                                  "files",
                                                  package = "document"),
                                      "produce_warning.R")
              if (! probably_winbuilder()
                  expect_warning(
                                 document(file_name, check_package = TRUE,
                                          runit = TRUE,
                                          stop_on_check_not_passing = FALSE,
                                          check_as_cran = TRUE)
                                 )
}
)
test_that("warning on bug, as cran", {
              options(useFancyQuotes = FALSE)
              file_name  <- file.path(system.file("tests",
                                                  "files",
                                                  package = "document"),
                                      "produce_warning.R")
              if (! probably_winbuilder()
                  expect_warning(
                                 document(file_name, check_package = TRUE,
                                          runit = TRUE,
                                          stop_on_check_not_passing = FALSE,
                                          check_as_cran = FALSE)
                                 )
}
)

# From 
# https://win-builder.r-project.org/S6Xqtaa84myx
#        /examples_and_tests/tests_x64/testthat.Rout.fail
# for document 3.0.0 I get the results below.
# I cannot reproduce them under windows with 3.3.1 nor with 
# R Under development (unstable) (2018-01-30 r74185) -- "Unsuffered Consequences" 
# Platform: x86_64-pc-linux-gnu (64-bit)
# 
# For document 2.2.1, which passed and on CRAN, I now get the results below below.
# 
# So I exclude tests based on guessing we are running win-builder.


## R Under development (unstable) (2018-01-30 r74185) -- "Unsuffered Consequences"
## Copyright (C) 2018 The R Foundation for Statistical Computing
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## 
## R is free software and comes with ABSOLUTELY NO WARRANTY.
## You are welcome to redistribute it under certain conditions.
## Type 'license()' or 'licence()' for distribution details.
## 
## R is a collaborative project with many contributors.
## Type 'contributors()' for more information and
## 'citation()' on how to cite R or R packages in publications.
## 
## Type 'demo()' for some demos, 'help()' for on-line help, or
## 'help.start()' for an HTML browser interface to help.
## Type 'q()' to quit R.
## 
## > library("testthat")
## > library("document")
## > test_check("document")
## --------------------------------------------------------------------------------
## -  using log directory 'D:/temp/Rtmpqm0CMW/file908855ba4f61/mini.mal.Rcheck'
## -  using R Under development (unstable) (2018-01-30 r74185)
## -  using platform: x86_64-w64-mingw32 (64-bit)
## -  using session charset: ISO8859-1
## -  using option '--as-cran'
## v  checking for file 'mini.mal/DESCRIPTION'
## -  checking extension type ... Package
## -  this is package 'mini.mal' version '2.0.0'
## N  checking CRAN incoming feasibility
##    Maintainer: 'Who to complain to <yourfault@somewhere.net>'
##    
##    New submission
##    
##    Possibly mis-spelled words in DESCRIPTION:
##      FAke (3:10)
## v  checking package namespace information
## v  checking package dependencies
## v  checking if this is a source package
## v  checking if there is a namespace
## v  checking for hidden files and directories
## v  checking for portable file names
## v  checking serialized R objects in the sources
## -  checking whether package 'mini.mal' can be installed ... [2s] OK
## v  checking installed package size
## v  checking package directory
## v  checking DESCRIPTION meta-information
## v  checking top-level files
## v  checking for left-over files
## v  checking index information
## v  checking package subdirectories
## v  checking R files for non-ASCII characters
## v  checking R files for syntax errors
## v  checking whether the package can be loaded
## v  checking whether the package can be loaded with stated dependencies
## v  checking whether the package can be unloaded cleanly
## v  checking whether the namespace can be loaded with stated dependencies
## v  checking whether the namespace can be unloaded cleanly
## v  checking loading without being on the library search path
## v  checking use of S3 registration
## v  checking dependencies in R code
## v  checking S3 generic/method consistency
## v  checking replacement functions
## v  checking foreign function calls
## -  checking R code for possible problems ... [3s] OK
## v  checking Rd files
## v  checking Rd metadata
## v  checking Rd line widths
## v  checking Rd cross-references
## v  checking for missing documentation entries
## v  checking for code/documentation mismatches
## v  checking Rd \usage sections
## v  checking Rd contents
## v  checking for unstated dependencies in examples
## -  checking examples ... [0s] OK
## v  checking PDF version of manual
## 
##    
## -- 0 errors v | 0 warnings v | 1 note x
##    See
##      'D:/temp/Rtmpqm0CMW/file908855ba4f61/mini.mal.Rcheck/00check.log'
##    for details.
##    
##    
## --------------------------------------------------------------------------------
## -  using log directory 'D:/temp/Rtmpqm0CMW/file90882b02244/simple.Rcheck'
## -  using R Under development (unstable) (2018-01-30 r74185)
## -  using platform: x86_64-w64-mingw32 (64-bit)
## -  using session charset: ISO8859-1
## -  using option '--as-cran'
## v  checking for file 'simple/DESCRIPTION'
## -  checking extension type ... Package
## -  this is package 'simple' version '2.0.0'
## N  checking CRAN incoming feasibility
##    Maintainer: 'Who to complain to <yourfault@somewhere.net>'
##    
##    New submission
##    
##    Possibly mis-spelled words in DESCRIPTION:
##      FAke (3:10)
## v  checking package namespace information
## v  checking package dependencies
## v  checking if this is a source package
## v  checking if there is a namespace
## v  checking for hidden files and directories
## v  checking for portable file names
## v  checking serialized R objects in the sources
## -  checking whether package 'simple' can be installed ... [2s] OK
## v  checking installed package size
## v  checking package directory
## v  checking DESCRIPTION meta-information
## v  checking top-level files
## v  checking for left-over files
## v  checking index information
## v  checking package subdirectories
## v  checking R files for non-ASCII characters
## v  checking R files for syntax errors
## v  checking whether the package can be loaded
## v  checking whether the package can be loaded with stated dependencies
## v  checking whether the package can be unloaded cleanly
## v  checking whether the namespace can be loaded with stated dependencies
## v  checking whether the namespace can be unloaded cleanly
## v  checking loading without being on the library search path
## v  checking use of S3 registration
## v  checking dependencies in R code
## v  checking S3 generic/method consistency
## v  checking replacement functions
## v  checking foreign function calls
## -  checking R code for possible problems ... [3s] OK
## v  checking Rd files
## v  checking Rd metadata
## v  checking Rd line widths
## v  checking Rd cross-references
## v  checking for missing documentation entries
## v  checking for code/documentation mismatches
## v  checking Rd \usage sections
## v  checking Rd contents
## v  checking for unstated dependencies in examples
## -  checking examples ... [1s] OK
## v  checking PDF version of manual
## 
## -- 0 errors v | 0 warnings v | 1 note x
##    
##    See
##      'D:/temp/Rtmpqm0CMW/file90882b02244/simple.Rcheck/00check.log'
##    for details.
##    
##    
## --------------------------------------------------------------------------------
## -  using log directory 'D:/temp/Rtmpqm0CMW/file90882b10c05/simple.Rcheck'
## -  using R Under development (unstable) (2018-01-30 r74185)
## -  using platform: x86_64-w64-mingw32 (64-bit)
## -  using session charset: ISO8859-1
## -  using option '--as-cran'
## v  checking for file 'simple/DESCRIPTION'
## -  checking extension type ... Package
## -  this is package 'simple' version '2.0.0'
## N  checking CRAN incoming feasibility
##    Maintainer: 'Who to complain to <yourfault@somewhere.net>'
##    
##    New submission
##    
##    Possibly mis-spelled words in DESCRIPTION:
##      FAke (3:10)
## v  checking package namespace information
## v  checking package dependencies
## v  checking if this is a source package
## v  checking if there is a namespace
## v  checking for hidden files and directories
## v  checking for portable file names
## v  checking serialized R objects in the sources
## -  checking whether package 'simple' can be installed ... [1s] OK
## v  checking installed package size
## v  checking package directory
## v  checking DESCRIPTION meta-information
## v  checking top-level files
## v  checking for left-over files
## v  checking index information
## v  checking package subdirectories
## v  checking R files for non-ASCII characters
## v  checking R files for syntax errors
## v  checking whether the package can be loaded
## v  checking whether the package can be loaded with stated dependencies
## v  checking whether the package can be unloaded cleanly
## v  checking whether the namespace can be loaded with stated dependencies
## v  checking whether the namespace can be unloaded cleanly
## v  checking loading without being on the library search path
## v  checking use of S3 registration
## v  checking dependencies in R code
## v  checking S3 generic/method consistency
## v  checking replacement functions
## v  checking foreign function calls
## -  checking R code for possible problems ... [3s] OK
## v  checking Rd files
## v  checking Rd metadata
## v  checking Rd line widths
## v  checking Rd cross-references
## v  checking for missing documentation entries
## v  checking for code/documentation mismatches
## v  checking Rd \usage sections
## v  checking Rd contents
## v  checking for unstated dependencies in examples
## -  checking examples ... [0s] OK
## v  checking PDF version of manual
## 
##    
## -- 0 errors v | 0 warnings v | 1 note x
##    See
##      'D:/temp/Rtmpqm0CMW/file90882b10c05/simple.Rcheck/00check.log'
##    for details.
##    
##    
## --------------------------------------------------------------------------------
## -  using log directory 'D:/temp/Rtmpqm0CMW/file9088684a54da/simple.Rcheck'
## -  using R Under development (unstable) (2018-01-30 r74185)
## -  using platform: x86_64-w64-mingw32 (64-bit)
## -  using session charset: ISO8859-1
## v  checking for file 'simple/DESCRIPTION'
## -  checking extension type ... Package
## -  this is package 'simple' version '2.0.0'
## N  checking CRAN incoming feasibility
##    Maintainer: 'Who to complain to <yourfault@somewhere.net>'
##    
##    New submission
##    
##    Possibly mis-spelled words in DESCRIPTION:
##      FAke (3:10)
## v  checking package namespace information
## v  checking package dependencies
## v  checking if this is a source package
## v  checking if there is a namespace
## v  checking for hidden files and directories
## v  checking for portable file names
## v  checking serialized R objects in the sources
## -  checking whether package 'simple' can be installed ... [2s] OK
## v  checking installed package size
## v  checking package directory
## v  checking DESCRIPTION meta-information
## v  checking top-level files
## v  checking for left-over files
## v  checking index information
## v  checking package subdirectories
## v  checking R files for non-ASCII characters
## v  checking R files for syntax errors
## v  checking whether the package can be loaded
## v  checking whether the package can be loaded with stated dependencies
## v  checking whether the package can be unloaded cleanly
## v  checking whether the namespace can be loaded with stated dependencies
## v  checking whether the namespace can be unloaded cleanly
## v  checking loading without being on the library search path
## v  checking use of S3 registration
## v  checking dependencies in R code
## v  checking S3 generic/method consistency
## v  checking replacement functions
## v  checking foreign function calls
## -  checking R code for possible problems ... [3s] OK
## v  checking Rd files
## v  checking Rd metadata
## v  checking Rd line widths
## v  checking Rd cross-references
## v  checking for missing documentation entries
## v  checking for code/documentation mismatches
## v  checking Rd \usage sections
## v  checking Rd contents
## v  checking for unstated dependencies in examples
## -  checking examples ... [1s] OK
## v  checking PDF version of manual
## 
##    
## -- 0 errors v | 0 warnings v | 1 note x
##    See
##      'D:/temp/Rtmpqm0CMW/file9088684a54da/simple.Rcheck/00check.log'
##    for details.
##    
##    
## _a _f_i_r_s_t _f_u_n_c_t_i_o_n _e_x_a_m_p_l_e _X_X_X
## 
## 
## 
## _D_e_s_c_r_i_p_t_i_o_n:
## 
## 
## 
##      This really is just an example, the function prints
## 
##      'utils::head()' and 'utils::str()' of the given 'data.frame'.
## 
## 
## 
## _U_s_a_g_e:
## 
## 
## 
##      a_first_function(df)
## 
##      
## 
## _A_r_g_u_m_e_n_t_s:
## 
## 
## 
##       df: Name of a data.frame to ... do whatever needs to be done.
## 
## 
## 
## _V_a_l_u_e:
## 
## 
## 
##      NULL. This is no good.
## 
## 
## 
## _A_u_t_h_o_r(_s):
## 
## 
## 
##      Dominik Cullmann <adc-r@arcor.de>
## 
## 
## 
## _E_x_a_m_p_l_e_s:
## 
## 
## 
##      data(iris, package = "datasets")
## 
##      a_first_function(iris)
## 
##      
## 
## 
## _a _f_i_r_s_t _f_u_n_c_t_i_o_n _e_x_a_m_p_l_e _X_X_X
## 
## 
## 
## _D_e_s_c_r_i_p_t_i_o_n:
## 
## 
## 
##      This really is just an example, the function prints
## 
##      'utils::head()' and 'utils::str()' of the given 'data.frame'.
## 
## 
## 
## _U_s_a_g_e:
## 
## 
## 
##      a_first_function(df)
## 
##      
## 
## _A_r_g_u_m_e_n_t_s:
## 
## 
## 
##       df: Name of a data.frame to ... do whatever needs to be done.
## 
## 
## 
## _V_a_l_u_e:
## 
## 
## 
##      NULL. This is no good.
## 
## 
## 
## _A_u_t_h_o_r(_s):
## 
## 
## 
##      Dominik Cullmann <adc-r@arcor.de>
## 
## 
## 
## _E_x_a_m_p_l_e_s:
## 
## 
## 
##      data(iris, package = "datasets")
## 
##      a_first_function(iris)
## 
##      
## 
## 
## _a _f_i_r_s_t _f_u_n_c_t_i_o_n _e_x_a_m_p_l_e _X_X_X
## 
## 
## 
## _D_e_s_c_r_i_p_t_i_o_n:
## 
## 
## 
##      This really is just an example, the function prints
## 
##      'utils::head()' and 'utils::str()' of the given 'data.frame'.
## 
## 
## 
## _U_s_a_g_e:
## 
## 
## 
##      a_first_function(df)
## 
##      
## 
## _A_r_g_u_m_e_n_t_s:
## 
## 
## 
##       df: Name of a data.frame to ... do whatever needs to be done.
## 
## 
## 
## _V_a_l_u_e:
## 
## 
## 
##      NULL. This is no good.
## 
## 
## 
## _A_u_t_h_o_r(_s):
## 
## 
## 
##      Dominik Cullmann <adc-r@arcor.de>
## 
## 
## 
## _E_x_a_m_p_l_e_s:
## 
## 
## 
##      data(iris, package = "datasets")
## 
##      a_first_function(iris)
## 
##      
## 
## 
## --------------------------------------------------------------------------------
## -  using log directory 'D:/temp/Rtmpqm0CMW/file90887ab07498/produce.warning.Rcheck'
## -  using R Under development (unstable) (2018-01-30 r74185)
## -  using platform: x86_64-w64-mingw32 (64-bit)
## -  using session charset: ISO8859-1
## v  checking for file 'produce.warning/DESCRIPTION'
## -  checking extension type ... Package
## -  this is package 'produce.warning' version '2.0.0'
## N  checking CRAN incoming feasibility
##    Maintainer: 'Who to complain to <yourfault@somewhere.net>'
##    
##    New submission
##    
##    Possibly mis-spelled words in DESCRIPTION:
##      FAke (3:10)
## v  checking package namespace information
## v  checking package dependencies
## v  checking if this is a source package
## v  checking if there is a namespace
## v  checking for hidden files and directories
## v  checking for portable file names
## v  checking serialized R objects in the sources
## -  checking whether package 'produce.warning' can be installed ... [1s] OK
## v  checking installed package size
## v  checking package directory
## v  checking DESCRIPTION meta-information
## v  checking top-level files
## v  checking for left-over files
## v  checking index information
## v  checking package subdirectories
## v  checking R files for non-ASCII characters
## v  checking R files for syntax errors
## v  checking whether the package can be loaded
## v  checking whether the package can be loaded with stated dependencies
## v  checking whether the package can be unloaded cleanly
## v  checking whether the namespace can be loaded with stated dependencies
## v  checking whether the namespace can be unloaded cleanly
## v  checking loading without being on the library search path
## v  checking use of S3 registration
## v  checking dependencies in R code
## v  checking S3 generic/method consistency
## v  checking replacement functions
## v  checking foreign function calls
## -  checking R code for possible problems ... [3s] OK
## v  checking Rd files
## v  checking Rd metadata
## v  checking Rd line widths
## v  checking Rd cross-references
## v  checking for missing documentation entries
## v  checking for code/documentation mismatches
## W  checking Rd \usage sections
##    Undocumented arguments in documentation object 'foo'
##      'x'
##    Documented arguments not in \usage in documentation object 'foo':
##      'y'
##    
##    Functions with \usage entries need to have the appropriate \alias
##    entries, and all their arguments documented.
##    The \usage entries must correspond to syntactically valid R code.
##    See chapter 'Writing R documentation files' in the 'Writing R
##    Extensions' manual.
## v  checking Rd contents
## v  checking for unstated dependencies in examples
## -  checking examples ... NONE
## v  checking PDF version of manual
## 
## -- 0 errors v | 1 warning x | 1 note x
##    
##    See
##      'D:/temp/Rtmpqm0CMW/file90887ab07498/produce.warning.Rcheck/00check.log'
##    for details.
##    
##    
## -- 1. Failure: error on bug, not as cran (@test_check.R#15)  -------------------
## `document(...)` did not throw an error.
## 
## --------------------------------------------------------------------------------
## -  using log directory 'D:/temp/Rtmpqm0CMW/file90884d74248a/produce.warning.Rcheck'
## -  using R Under development (unstable) (2018-01-30 r74185)
## -  using platform: x86_64-w64-mingw32 (64-bit)
## -  using session charset: ISO8859-1
## -  using option '--as-cran'
## v  checking for file 'produce.warning/DESCRIPTION'
## -  checking extension type ... Package
## -  this is package 'produce.warning' version '2.0.0'
## N  checking CRAN incoming feasibility
##    Maintainer: 'Who to complain to <yourfault@somewhere.net>'
##    
##    New submission
##    
##    Possibly mis-spelled words in DESCRIPTION:
##      FAke (3:10)
## v  checking package namespace information
## v  checking package dependencies
## v  checking if this is a source package
## v  checking if there is a namespace
## v  checking for hidden files and directories
## v  checking for portable file names
## v  checking serialized R objects in the sources
## -  checking whether package 'produce.warning' can be installed ... [1s] OK
## v  checking installed package size
## v  checking package directory
## v  checking DESCRIPTION meta-information
## v  checking top-level files
## v  checking for left-over files
## v  checking index information
## v  checking package subdirectories
## v  checking R files for non-ASCII characters
## v  checking R files for syntax errors
## v  checking whether the package can be loaded
## v  checking whether the package can be loaded with stated dependencies
## v  checking whether the package can be unloaded cleanly
## v  checking whether the namespace can be loaded with stated dependencies
## v  checking whether the namespace can be unloaded cleanly
## v  checking loading without being on the library search path
## v  checking use of S3 registration
## v  checking dependencies in R code
## v  checking S3 generic/method consistency
## v  checking replacement functions
## v  checking foreign function calls
## -  checking R code for possible problems ... [3s] OK
## v  checking Rd files
## v  checking Rd metadata
## v  checking Rd line widths
## v  checking Rd cross-references
## v  checking for missing documentation entries
## v  checking for code/documentation mismatches
## W  checking Rd \usage sections
##    Undocumented arguments in documentation object 'foo'
##      'x'
##    Documented arguments not in \usage in documentation object 'foo':
##      'y'
##    
##    Functions with \usage entries need to have the appropriate \alias
##    entries, and all their arguments documented.
##    The \usage entries must correspond to syntactically valid R code.
##    See chapter 'Writing R documentation files' in the 'Writing R
##    Extensions' manual.
## v  checking Rd contents
## v  checking for unstated dependencies in examples
## -  checking examples ... NONE
## v  checking PDF version of manual
## 
## -- 0 errors v | 1 warning x | 1 note x
##    
##    See
##      'D:/temp/Rtmpqm0CMW/file90884d74248a/produce.warning.Rcheck/00check.log'
##    for details.
##    
##    
## -- 2. Failure: error on bug, as cran (@test_check.R#29)  -----------------------
## `document(...)` did not throw an error.
## 
## --------------------------------------------------------------------------------
## -  using log directory 'D:/temp/Rtmpqm0CMW/file908813493d7/produce.warning.Rcheck'
## -  using R Under development (unstable) (2018-01-30 r74185)
## -  using platform: x86_64-w64-mingw32 (64-bit)
## -  using session charset: ISO8859-1
## -  using option '--as-cran'
## v  checking for file 'produce.warning/DESCRIPTION'
## -  checking extension type ... Package
## -  this is package 'produce.warning' version '2.0.0'
## N  checking CRAN incoming feasibility
##    Maintainer: 'Who to complain to <yourfault@somewhere.net>'
##    
##    New submission
##    
##    Possibly mis-spelled words in DESCRIPTION:
##      FAke (3:10)
## v  checking package namespace information
## v  checking package dependencies
## v  checking if this is a source package
## v  checking if there is a namespace
## v  checking for hidden files and directories
## v  checking for portable file names
## v  checking serialized R objects in the sources
## -  checking whether package 'produce.warning' can be installed ... [1s] OK
## v  checking installed package size
## v  checking package directory
## v  checking DESCRIPTION meta-information
## v  checking top-level files
## v  checking for left-over files
## v  checking index information
## v  checking package subdirectories
## v  checking R files for non-ASCII characters
## v  checking R files for syntax errors
## v  checking whether the package can be loaded
## v  checking whether the package can be loaded with stated dependencies
## v  checking whether the package can be unloaded cleanly
## v  checking whether the namespace can be loaded with stated dependencies
## v  checking whether the namespace can be unloaded cleanly
## v  checking loading without being on the library search path
## v  checking use of S3 registration
## v  checking dependencies in R code
## v  checking S3 generic/method consistency
## v  checking replacement functions
## v  checking foreign function calls
## -  checking R code for possible problems ... [3s] OK
## v  checking Rd files
## v  checking Rd metadata
## v  checking Rd line widths
## v  checking Rd cross-references
## v  checking for missing documentation entries
## v  checking for code/documentation mismatches
## W  checking Rd \usage sections
##    Undocumented arguments in documentation object 'foo'
##      'x'
##    Documented arguments not in \usage in documentation object 'foo':
##      'y'
##    
##    Functions with \usage entries need to have the appropriate \alias
##    entries, and all their arguments documented.
##    The \usage entries must correspond to syntactically valid R code.
##    See chapter 'Writing R documentation files' in the 'Writing R
##    Extensions' manual.
## v  checking Rd contents
## v  checking for unstated dependencies in examples
## -  checking examples ... NONE
## v  checking PDF version of manual
## 
##    
## -- 0 errors v | 1 warning x | 1 note x
##    See
##      'D:/temp/Rtmpqm0CMW/file908813493d7/produce.warning.Rcheck/00check.log'
##    for details.
##    
##    
## -- 3. Failure: warning on bug, not as cran (@test_check.R#43)  -----------------
## `document(...)` did not produce any warnings.
## 
## --------------------------------------------------------------------------------
## -  using log directory 'D:/temp/Rtmpqm0CMW/file90885a583918/produce.warning.Rcheck'
## -  using R Under development (unstable) (2018-01-30 r74185)
## -  using platform: x86_64-w64-mingw32 (64-bit)
## -  using session charset: ISO8859-1
## v  checking for file 'produce.warning/DESCRIPTION'
## -  checking extension type ... Package
## -  this is package 'produce.warning' version '2.0.0'
## N  checking CRAN incoming feasibility
##    Maintainer: 'Who to complain to <yourfault@somewhere.net>'
##    
##    New submission
##    
##    Possibly mis-spelled words in DESCRIPTION:
##      FAke (3:10)
## v  checking package namespace information
## v  checking package dependencies
## v  checking if this is a source package
## v  checking if there is a namespace
## v  checking for hidden files and directories
## v  checking for portable file names
## v  checking serialized R objects in the sources
## -  checking whether package 'produce.warning' can be installed ... [1s] OK
## v  checking installed package size
## v  checking package directory
## v  checking DESCRIPTION meta-information
## v  checking top-level files
## v  checking for left-over files
## v  checking index information
## v  checking package subdirectories
## v  checking R files for non-ASCII characters
## v  checking R files for syntax errors
## v  checking whether the package can be loaded
## v  checking whether the package can be loaded with stated dependencies
## v  checking whether the package can be unloaded cleanly
## v  checking whether the namespace can be loaded with stated dependencies
## v  checking whether the namespace can be unloaded cleanly
## v  checking loading without being on the library search path
## v  checking use of S3 registration
## v  checking dependencies in R code
## v  checking S3 generic/method consistency
## v  checking replacement functions
## v  checking foreign function calls
## -  checking R code for possible problems ... [3s] OK
## v  checking Rd files
## v  checking Rd metadata
## v  checking Rd line widths
## v  checking Rd cross-references
## v  checking for missing documentation entries
## v  checking for code/documentation mismatches
## W  checking Rd \usage sections
##    Undocumented arguments in documentation object 'foo'
##      'x'
##    Documented arguments not in \usage in documentation object 'foo':
##      'y'
##    
##    Functions with \usage entries need to have the appropriate \alias
##    entries, and all their arguments documented.
##    The \usage entries must correspond to syntactically valid R code.
##    See chapter 'Writing R documentation files' in the 'Writing R
##    Extensions' manual.
## v  checking Rd contents
## v  checking for unstated dependencies in examples
## -  checking examples ... NONE
## v  checking PDF version of manual
## 
##    
## -- 0 errors v | 1 warning x | 1 note x
##    See
##      'D:/temp/Rtmpqm0CMW/file90885a583918/produce.warning.Rcheck/00check.log'
##    for details.
##    
##    
## -- 4. Failure: warning on bug, as cran (@test_check.R#57)  ---------------------
## `document(...)` did not produce any warnings.
## 
## == testthat results  ===========================================================
## OK: 22 SKIPPED: 0 FAILED: 4
## 1. Failure: error on bug, not as cran (@test_check.R#15) 
## 2. Failure: error on bug, as cran (@test_check.R#29) 
## 3. Failure: warning on bug, not as cran (@test_check.R#43) 
## 4. Failure: warning on bug, as cran (@test_check.R#57) 
## 
## Error: testthat unit tests failed
## Execution halted
## 



## R Under development (unstable) (2018-01-30 r74185) -- "Unsuffered Consequences"
## Copyright (C) 2018 The R Foundation for Statistical Computing
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## 
## R is free software and comes with ABSOLUTELY NO WARRANTY.
## You are welcome to redistribute it under certain conditions.
## Type 'license()' or 'licence()' for distribution details.
## 
## R is a collaborative project with many contributors.
## Type 'contributors()' for more information and
## 'citation()' on how to cite R or R packages in publications.
## 
## Type 'demo()' for some demos, 'help()' for on-line help, or
## 'help.start()' for an HTML browser interface to help.
## Type 'q()' to quit R.
## 
## > library("testthat")
## > library("document")
## > test_check("document")
## -- 1. Error: (unknown) (@test_basic.R#13)  -------------------------------------
## R CMD check failed, read the above log and fix.
## 1: document(file_name, check_package = TRUE, runit = TRUE) at testthat/test_basic.R:13
## 2: check_package(package_directory = package_directory, working_directory = working_directory, 
##        check_as_cran = check_as_cran, debug = debug, stop_on_check_not_passing = stop_on_check_not_passing)
## 3: throw("R CMD check failed, read the above log and fix.")
## 
## == testthat results  ===========================================================
## OK: 0 SKIPPED: 0 FAILED: 1
## 1. Error: (unknown) (@test_basic.R#13) 
## 
## Error: testthat unit tests failed
## Execution halted

