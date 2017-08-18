Dear CRAN Team,
this is a resubmission of package document. I have added the following changes:

* Fix *man()* to now work with RStudio.
* Add and export a new function *alter\_description\_file()*.
  It serves as a replacement for the internal
  *add\_depenedencies\_to\_description()*, and straightens the former internal
  *clean\_descprition()* which used [*write|read]Lines()* instead of
  [*write|read].dcf()* and is now exported as *clean\_descprition\_file()*.

Please upload to CRAN.
Best, Dominik

# Package document2.1.0
## Test  environments 
-R Under development (unstable) (2017-08-03 r73028)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Devuan GNU/Linux 1 (jessie)
-R version 3.4.1 (2017-06-30)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Ubuntu precise (12.04.5 LTS)
- win-builder (devel)

## R CMD check results
0 errors | 0 warnings | 0 notes
