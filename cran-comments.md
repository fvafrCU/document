Dear CRAN Team,
this is a resubmission of package document 1.0.0.
I have run package profvis on the examples from document() and man() but could
not figure how to reduce cpu times. The package roxygenizes, builds and checks
(chunks of) single R code files. To me, there seems no way to get around these
cpu times. I've again disabled the examples of the package's two main functions,
document() and man(), using \donttest{} to pass R CMD check --as-cran.
I have included the NOTEs from  R CMD check --as-cran --run-donttest. They
affect the two main functions, document() and man(). I guess this is what users
of the package will to pay for building, roxygenizing, building and checking 
theirs codes.
I have included the output from running covr on the package below: I heavily 
test the code. Please see 
https://codecov.io/github/fvafrCU/document?branch=master for third party
results.

I hope this adjustments will take it to CRAN,
best,
Dominik Cullmann


> Indeed, we see
> 
> Examples with CPU or elapsed time > 10s
>          user system elapsed
> document 1.68   0.12   44.37
> man      0.14   0.06   12.93
> 
> Can you reduce these to roughly 5 sec each?
> 
> If not, it is OK to have some examples in \donttest{} here, but pelase try to
> ptovide at least some tgoy examples for each major function in your package.
> 
> Best,
> Uwe Ligges
> On 06.05.2017 22:11, Andreas Dominik Cullmann wrote:
> > Dear CRAN Team,
> > I have resubmitted the package via the web form with most examples enabled.
> > Since they build and check temporary packages
> > (using devtools::build(), and callr::rcmd_safe()),
> > they eat quite some cpu time.
> >
> > Best,
> > Dominik Cullmann
> >
> > On Sat, May 06, 2017 00:00:24, Uwe Ligges wrote:
> >> Thanks, we see that almost all your examples are wrapped in \dontrun{} and
> >> hence the code does not get tested.
> >> Can'y you move some examples outside of \dontrun{}?
> >>
> >> Best,
> >> Uwe Ligges

# Package  document 1.0.0 

## Test  environments  
- R Under development (unstable) (2017-04-25 r72618)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Debian GNU/Linux 8 (jessie) 
- R version 3.4.0 (2017-04-21)
  Platform: x86_64-pc-linux-gnu (64-bit)
  Running under: Ubuntu precise (12.04.5 LTS) 
- win-builder (devel) 

## R CMD check results
0 errors | 0 warnings | 1 note 
checking CRAN incoming feasibility ... NOTE
Maintainer: ‘Andreas Dominik Cullmann <adc-r@arcor.de>’

New submission

## R CMD check  --dont-test results
0 errors | 0 warnings | 2 notes
checking CRAN incoming feasibility ... NOTE
Maintainer: ‘Andreas Dominik Cullmann <adc-r@arcor.de>’

New submission

checking examples ... NOTE
Examples with CPU or elapsed time > 5s
          user system elapsed
man      6.988  0.868   8.877
document 4.496  0.412   5.439

## results from covr::package_coverage(path = ".", function_exclusions = "\\.onLoad")
        filename      functions line value
212 R/document.R write_the_docs  180     0
215 R/document.R write_the_docs  183     0
document Coverage: 99.16%
R/document.R: 98.08%
R/file_parsing.R: 100.00%
R/man.R: 100.00%
R/utils.R: 100.00%
