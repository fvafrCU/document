Dear CRAN Team,
this is a resubmission of package 'document'. I have added the following changes:

* Added a fix to make the evaluation of whether or not/how we pass R CMD check 
  more stable by using rcmdcheck internally.
  This causes the `check_result`-item of the list returned by document() to 
  change: it is now the return value of rcmdcheck::rcmdcheck() instead of the
  return value of callr::rcmd\_safe("check", ...).

Please upload to CRAN.
Best, Andreas Dominik

# Package document 3.0.0
## Test  environments 
- R Under development (unstable) (2018-01-12 r74112)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Devuan GNU/Linux 1 (jessie)
- R version 3.4.2 (2017-01-27)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Ubuntu 14.04.5 LTS
- win-builder (devel)

## R CMD check results
0 errors | 0 warnings | 0 notes
