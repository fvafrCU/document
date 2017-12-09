Dear CRAN Team,
this is a resubmission of package 'document'. I have added the following changes:

* Marked *alter\_descprition\_file()* as deprecated, please use CRAN package 
  `desc` by Gabor Csardi instead.  
  Internally, *alter\_descprition\_file()* is not used any longer. 
  It just lingers as it was exported in version 2.1.0.
* *alter\_descprition\_file()* now keeps whitespace, making it possible to pass 
  newline characters, for example for the Authors@R field.

Please upload to CRAN.
Best, Dominik

# Package document 2.2.0
## Test  environments 
- R Under development (unstable) (2017-11-07 r73685)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Devuan GNU/Linux 1 (jessie)
- R version 3.4.2 (2017-01-27)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Ubuntu 14.04.5 LTS
- win-builder (devel)

## R CMD check results
0 errors | 0 warnings | 0 notes
