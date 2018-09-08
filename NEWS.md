# document 3.0.2

* Patched failing "CRAN Package Check Results for Package document".

# document 3.0.0

* Added a fix to make the evaluation of whether or not/how we pass R CMD check 
  more stable by using rcmdcheck internally.
  This causes the `check_result`-item of the list returned by document() to 
  change: it is now the return value of rcmdcheck::rcmdcheck() instead of the
  return value of callr::rcmd\_safe("check", ...).
* The (internal) functions 
  - *is\_Rd\_file*
  - *display\_Rd*
  - *fake\_package*
  - *check\_package*
  - *sort\_unlocale*
  - *alter\_description\_file*
  - *Rd\_txt\_RUnit*
  are not exported any longer.

# document 2.2.1

* Fixed internal file parsing.
* Exported function get\_lines\_between\_tags().

# document 2.2.0

* Marked *alter\_descprition\_file()* as deprecated, please use CRAN package 
  `desc` by Gabor Csardi instead.  
  Internally, *alter\_descprition\_file()* is not used any longer. 
  It just lingers as it was exported in version 2.1.0.
* *alter\_descprition\_file()* now keeps whitespace, making it possible to pass 
  newline characters, for example for the Authors@R field.

# document 2.1.0

* Fix *man()* to now work with RStudio.
* Add and export a new function *alter\_description\_file()*.
  It serves as a replacement for the internal
  *add\_depenedencies\_to\_description()*, and straightens the former internal
  *clean\_descprition()* which used [*write|read]Lines()* instead of
  [*write|read].dcf()* and is now exported as *clean\_descprition\_file()*.

# document 2.0.0

* *document()* now throws an error if the temporary package does not pass R CMD
  check without errors, warnings or notes. 
  - Added argument 'stop\_on\_check\_not\_passing'. Set to FALSE to issue a
    *warning()* instead of throwing an error.
  - Added argument 'check\_as\_cran' to use the --as-cran flag with R CMD check,
    *document()* then assumes a single NOTE (on the CRAN incoming feasibility) 
    to be okay.

# document 1.2.1

* Check for RStudio in *man()*.
* Fix return status of *write\_the\_docs()*.

# document 1.2.0

* Enhance documenation.

# document 1.1.0

* Use the input file's basename instead of the temporary package's name as
  basename for the output files.
* Only return output file paths if the according file exists.

# document 1.0.0

* First release. See https://github.com/fvafrCU/document for any changes before.




