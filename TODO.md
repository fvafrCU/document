- tag commit  9459921427e0be1771f2f8f9cb11e5e8a81a75e1  as  3.0.0 , once package is on CRAN.
- improve vignette
- make it pass testing on current windows (winbuilder, rhub)!
- get rid of empty .Rd2pdfxxx-dirs in testing. They might get created by devtools::load_all()
- Tag commit f22262a5fd8608ae1c42f62c48e43ca31bae8f6e as 3.0.1, once package is on CRAN using
	git tag -a 3.0.1 f22262a5fd8608ae1c42f62c48e43ca31bae8f6e -m'CRAN release'
