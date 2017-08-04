# document 2.0.0

* document() now throws an error if the temporary package does not pass R CMD
  check without errors, warnings or notes. 
  - Added argument 'stop\_on\_check\_not\_passing'. Set to FALSE to issue a
    warning() instead of throwing an error.
  - Added argument 'check\_as\_cran' to use the --as-cran flag with R CMD check,
    document() then assumes a single NOTE (on the CRAN incoming feasibility) to
    be okay.

# document 1.2.1

* Check for RStudio in man().
* Fix return status of write\_the\_docs().

# document 1.2.0

* Enhance documenation.

# document 1.1.0

* Use the input file's basename instead of the temporary package's name as
  basename for the output files.
* Only return output file paths if the according file exists.

# document 1.0.0

* First release. See https://github.com/fvafrCU/document for any changes before.




