PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)
R_FILES := $(shell find R/ -type f)
MAN_FILES := $(shell find man/ -type f)
TESTS_FILES := $(shell find tests/ -type f)
RUNIT_FILES := $(shell find tests/ -type f | grep  'runit')
TESTTHAT_FILES := $(shell find tests/ -type f | grep  'testthat')
VIGNETTES_FILES := $(shell find vignettes/ -type f)
DEPS := "callr", "rprojroot", "covr", "knitr", "devtools", "rmarkdown", "RUnit", "checkmate", "roxygen2", "lintr", "hunspell", "roxygen2", "devtools"

TEMP_FILE := $(shell tempfile)
LOG_DIR := log

R := R-devel
Rscript := Rscript-devel

.PHONY: all
all: install utils 

#% devtools
# a loose collection of helpful stuff while developing

.PHONY: devtools
devtools: cran_comments use_dev_version dependencies_forced vignettes codetags tag

.PHONY: tag
tag: ${LOG_DIR}/git_tag.Rout 
${LOG_DIR}/git_tag.Rout: ${LOG_DIR}/install.Rout  
	${R} --vanilla -e 'source(file.path("utils", "git_tag.R")); git_tag()' > ${LOG_DIR}/git_tag.Rout 

.PHONY: codetags
codetags: ${LOG_DIR}/check_codetags.Rout 
${LOG_DIR}/check_codetags.Rout:
	${Rscript} --vanilla -e 'source(file.path("utils", "checks.R")); check_codetags()' > ${LOG_DIR}/check_codetags.Rout 2>&1 

.PHONY: build_win
build_win:
	echo "Run \n \t${Rscript} --vanilla -e 'devtools::build_win()'"

.PHONY: release
release: build_win
	echo "Run \n \t${Rscript} interacitvely and do 'devtools::release(check = FALSE)'"

.PHONY: vignettes
vignettes:
	${Rscript} --vanilla -e 'devtools::build_vignettes()'

cran-comments.md: ${LOG_DIR}/dev_check.Rout
	${Rscript} --vanilla -e 'source("./utils/cran_comments.R"); provide_cran_comments(check_log = "log/dev_check.Rout")' > ${LOG_DIR}/cran_comments.Rout 2>&1 
	
# rerun check without --run-donttest to create Rout for cran-comments
.PHONY: dev_check
dev_check: ${LOG_DIR}/dev_check.Rout
${LOG_DIR}/dev_check.Rout: ${PKGNAME}_${PKGVERS}.tar.gz
	rm ${TEMP_FILE} || true; \
		${Rscript} --vanilla -e 'devtools::check(cran = TRUE, check_version = TRUE, args = "--no-tests")' > ${TEMP_FILE} 2>&1; \
		grep -v ".*'/" ${TEMP_FILE} | grep -v ".*‘/" > ${LOG_DIR}/dev_check.Rout ;\
		grep "checking tests ... SKIPPED" ${LOG_DIR}/dev_check.Rout

.PHONY: use_dev_version
use_dev_version: ${LOG_DIR}/use_dev_version.Rout
.PHONY: ${LOG_DIR}/use_dev_version.Rout
${LOG_DIR}/use_dev_version.Rout:
	${Rscript} --vanilla -e 'devtools::use_dev_version()' > ${LOG_DIR}/use_dev_version.Rout 2>&1 

.PHONY: dependencies_forced
dependencies_forced: ${LOG_DIR}/dependencies_forced.Rout
${LOG_DIR}/dependencies_forced.Rout:
	${Rscript} --vanilla -e 'deps <-c(${DEPS}); for (dep in deps) install.packages(dep, repos = "https://cran.uni-muenster.de/")' > ${LOG_DIR}/dependencies_forced.Rout 2>&1 

#% install

.PHONY: install
install: ${LOG_DIR}/install.Rout
${LOG_DIR}/install.Rout: ${LOG_DIR}/check.Rout
	${R} --vanilla CMD INSTALL  ${PKGNAME}_${PKGVERS}.tar.gz > ${LOG_DIR}/install.Rout 2>&1 

# run check with --run-donttest 
.PHONY: check
check: ${LOG_DIR}/check.Rout
${LOG_DIR}/check.Rout: ${PKGNAME}_${PKGVERS}.tar.gz
	export _R_CHECK_FORCE_SUGGESTS_=TRUE && \
		export R_LIBS_USER="/home/qwer/svn/R/r-devel/build/library" && \
		${R} --vanilla CMD check --as-cran --run-donttest \
		${PKGNAME}_${PKGVERS}.tar.gz ; \
		cp ${PKGNAME}.Rcheck/00check.log ${LOG_DIR}/check.Rout

.PHONY: build
build: ${PKGNAME}_${PKGVERS}.tar.gz
${PKGNAME}_${PKGVERS}.tar.gz: ${R_FILES} ${MAN_FILES} ${TESTS_FILES} ${VIGNETTE_FILES} NEWS.md README.md DESCRIPTION LICENSE ${LOG_DIR}/roxygen2.Rout ${LOG_DIR}/spell.Rout  ${LOG_DIR}/news.Rout ${LOG_DIR}/dependencies.Rout
	${R} --vanilla CMD build ../${PKGSRC}

${LOG_DIR}/news.Rout: DESCRIPTION NEWS.md
	${Rscript} --vanilla -e 'source(file.path("utils", "checks.R")); check_news()' > ${LOG_DIR}/news.Rout 2>&1 

.PHONY: spell
spell: ${LOG_DIR}/spell.Rout
${LOG_DIR}/spell.Rout: ${MAN_FILES} DESCRIPTION ${LOG_DIR}/roxygen2.Rout 
	${Rscript} --vanilla -e 'spell <- devtools::spell_check(); if (length(spell) > 0) {print(spell); warning("spell check failed")} ' > ${LOG_DIR}/spell.Rout 2>&1 

${LOG_DIR}/roxygen2.Rout: ${R_FILES}
	${R} --vanilla -e 'roxygen2::roxygenize(".")' > ${LOG_DIR}/roxygen2.Rout 2>&1 

README.md: README.Rmd 
	${Rscript} --vanilla -e 'knitr::knit("README.Rmd")'

.PHONY: dependencies
dependencies: ${LOG_DIR}/dependencies.Rout
.PHONY: ${LOG_DIR}/dependencies.Rout
${LOG_DIR}/dependencies.Rout:
	${Rscript} --vanilla -e 'deps <-c(${DEPS}); for (dep in deps) {if (! require(dep, character.only = TRUE)) install.packages(dep, repos = "https://cran.uni-muenster.de/")}' > ${LOG_DIR}/dependencies.Rout 2>&1 


#% devel

.PHONY: devel
devel: ${LOG_DIR}/cleanr.Rout ${LOG_DIR}/lintr.Rout ${LOG_DIR}/covr.Rout ${LOG_DIR}/runit.Rout ${LOG_DIR}/testthat.Rout

.PHONY: coverage
coverage: ${LOG_DIR}/covr.Rout 
${LOG_DIR}/covr.Rout: ${R_FILES} ${TESTS_FILES}
	${Rscript} --vanilla -e 'co <- covr::package_coverage(path = ".", function_exclusions = "\\.onLoad"); covr::zero_coverage(co); print(co)' > ${LOG_DIR}/covr.Rout 2>&1 

.PHONY: cleanr
cleanr: ${LOG_DIR}/cleanr.Rout 
${LOG_DIR}/cleanr.Rout: ${R_FILES}
	${Rscript} --vanilla -e 'print(cleanr::check_directory("R/",  max_num_arguments = 9, check_return = FALSE))' > ${LOG_DIR}/cleanr.Rout 2>&1 

.PHONY: lintr
lintr: ${LOG_DIR}/lintr.Rout 
${LOG_DIR}/lintr.Rout: ${R_FILES}
	rm inst/doc/*.R || true
	${Rscript} --vanilla utils/lintr.R > ${LOG_DIR}/lintr.Rout 2>&1 

.PHONY: testthat
testthat: ${LOG_DIR}/testthat.Rout 
${LOG_DIR}/testthat.Rout: ${R_FILES} ${TESTTHAT_FILES}
	rm ${TEMP_FILE} || true; \
		${Rscript} --vanilla -e 'devtools::test()' >  ${TEMP_FILE} 2>&1; \
		sed -n -e '/^DONE.*/q;p' < ${TEMP_FILE} | \
		sed -e "s# /.*\(${PKGNAME}\)# \1#" > ${LOG_DIR}/testthat.Rout; rm ${TEMP_FILE}

.PHONY: runit
runit: ${LOG_DIR}/runit.Rout
${LOG_DIR}/runit.Rout: ${R_FILES} ${RUNIT_FILES}
	cd ./tests/ && ${Rscript} --vanilla ./runit.R > ../../${LOG_DIR}/runit.Rout 2>&1 || printf "\nMaybe your installation is stale? \nTry\n\tmake install_bare\n\n"

#% utils
.PHONY: clean
clean:
	rm -rf ${PKGNAME}.Rcheck

.PHONY: remove
remove:
	 ${R} --vanilla CMD REMOVE  ${PKGNAME}

# visualize the Makefile
.PHONY: viz
viz: ${LOG_DIR}/make_all.png ${LOG_DIR}/make_devel.png
${LOG_DIR}/make_all.png: Makefile
	make -Bnd all | makefile2graph | dot -Tpng -o ${LOG_DIR}/make_all.png

${LOG_DIR}/make_devel.png: Makefile
	make -nd devel | makefile2graph | dot -Tpng -o ${LOG_DIR}/make_devel.png

# bare build to install or run test without spell checking and such
.PHONY: build_bare
build_bare:
	${R} --vanilla CMD build ../${PKGSRC}
