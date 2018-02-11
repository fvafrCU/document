Dear CRAN Team,
this is a resubmission of package 'document'. I have added the following changes:

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

Please upload to CRAN.
Best, Andreas Dominik

# Package document 3.0.0
## Test  environments 
- R Under development (unstable) (2018-02-09 r74240)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Devuan GNU/Linux 1 (jessie)
- R version 3.4.2 (2017-01-27)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Ubuntu 14.04.5 LTS
- win-builder (devel)

## R CMD check results
0 errors | 0 warnings | 0 notes
