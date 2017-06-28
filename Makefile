# inspired by https://raw.githubusercontent.com/yihui/knitr/master/Makefile
PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)
R_FILES := $(shell find R/ -type f)
MAN_FILES := $(shell find man/ -type f)
TESTS_FILES := $(shell find tests/ -type f | egrep  -E '(testthat|runit)') # XXX: Do not grep.
VIGNETTES_FILES := $(shell find vignettes/ -type f)


temp_file := $(shell tempfile)
lintr_script := utils/lintr.R
LOG_DIR := log

R := R-devel
Rscript := Rscript-devel

all: ${LOG_DIR}/install.log 

devel: utils dev_check dev_vignettes dev_check_bare dev_check_dont dev_test dev_win dev_release dev_devel

# devtools

dev_check_bare:
	rm ${temp_file} || true; \
		${Rscript} --vanilla -e 'devtools::check(cran = TRUE, check_version = TRUE, args = "--no-tests")' > ${temp_file} 2>&1; \
		grep -v ".*'/" ${temp_file} | grep -v ".*‘/" > ${LOG_DIR}/dev_check.Rout ;\
		grep "checking tests ... SKIPPED" ${LOG_DIR}/dev_check.Rout

dev_check_dont: 
	rm ${temp_file} || true; \
		${Rscript} --vanilla -e 'devtools::check(cran = TRUE, check_version = TRUE, args = "--run-donttest")' > ${temp_file} 2>&1; \
		grep -v ".*'/" ${temp_file} | grep -v ".*‘/" > ${LOG_DIR}/dev_check_dont.Rout ;\

dev_check: dev_test 
	rm ${temp_file} || true; \
		${Rscript} --vanilla -e 'devtools::check(cran = TRUE, check_version = TRUE, args = "--no-tests")' > ${temp_file} 2>&1; \
		grep -v ".*'/" ${temp_file} | grep -v ".*‘/" > ${LOG_DIR}/dev_check.Rout ;\
		grep "checking tests ... SKIPPED" ${LOG_DIR}/dev_check.Rout

dev_test:
	rm ${temp_file} || true; \
	${Rscript} --vanilla -e 'devtools::test()' >  ${temp_file} 2>&1; \
	sed -n -e '/^DONE.*/q;p' < ${temp_file} | \
	sed -e "s# /.*\(${PKGNAME}\)# \1#" > ${LOG_DIR}/dev_test.Rout; rm ${temp_file}

dev_vignettes:
	${Rscript} --vanilla -e 'devtools::build_vignettes()'

dev_win:
	${Rscript} --vanilla -e 'devtools::build_win()'

dev_release: dev_win
	echo "${Rscript} --vanilla -e 'devtools::release(check = FALSE)'"

dev_devel:
	${Rscript} --vanilla -e 'devtools::use_dev_version()'



# utils
.PHONY: utils
utils: cleanr lintr coverage 

.PHONY: runit
runit:
	cd ./tests/ && ${Rscript} --vanilla ./runit.R > ../../${LOG_DIR}/runit.Rout 2>&1 || printf "\nMaybe your installation is stale? \nTry\n\tmake install_bare\n\n"

.PHONY: coverage
coverage:
	${Rscript} --vanilla -e 'co <- covr::package_coverage(path = ".", function_exclusions = "\\.onLoad"); covr::zero_coverage(co); print(co)' > ${LOG_DIR}/covr.Rout 2>&1 


.PHONY: cleanr
cleanr:
	${Rscript} --vanilla -e 'print(cleanr::check_directory("R/",  max_num_arguments = 9, check_return = FALSE))' > ${LOG_DIR}/cleanr.Rout 2>&1 

.PHONY: lintr
lintr:
	rm inst/doc/*.R || true
	${Rscript} --vanilla ${lintr_script} > ${LOG_DIR}/lintr.Rout 2>&1 

.PHONY: clean
clean:
	rm -rf ${PKGNAME}.Rcheck

.PHONY: remove
remove:
	 ${R} --vanilla CMD REMOVE  ${PKGNAME}


# specifics
cran-comments.md: log/dev_check.Rout
	${Rscript} --vanilla -e 'source("./utils/cran_comments.R"); provide_cran_comments()' > log/cran_comments.Rout 2>&1 


.PHONY: fixes
fixes:
	./utils/fixes.cl

##% git tag
.PHONY: tag
tag:
	./utils/tag.cl

.PHONY: dependencies
dependencies:
	${Rscript} --vanilla -e 'deps <-c("callr", "rprojroot", "covr", "knitr", "devtools", "rmarkdown", "RUnit", "checkmate", "roxygen2", "lintr", "hunspell"); for (dep in deps) {if (! require(dep, character.only = TRUE)) install.packages(dep, repos = "https://cran.uni-muenster.de/")}'

.PHONY: dependencies_forced
dependencies_forced:
	${Rscript} --vanilla -e 'deps <-c("callr", "rprojroot", "covr", "knitr", "devtools", "rmarkdown", "RUnit", "checkmate", "roxygen2", "lintr", "hunspell"); for (dep in deps) install.packages(dep, repos = "https://cran.uni-muenster.de/")'


##: TODO 
# R CMD 
.PHONY: install
install: ${LOG_DIR}/install.log
${LOG_DIR}/install.log: ${LOG_DIR}/check.log
	${R} --vanilla CMD INSTALL  ${PKGNAME}_${PKGVERS}.tar.gz > ${LOG_DIR}/install.log 2>&1 


.PHONY: check
check: ${LOG_DIR}/check.log
${LOG_DIR}/check.log: ${PKGNAME}_${PKGVERS}.tar.gz
	export _R_CHECK_FORCE_SUGGESTS_=TRUE && \
		${R} --vanilla CMD check --as-cran --run-donttest \
		${PKGNAME}_${PKGVERS}.tar.gz && \
		cp ${PKGNAME}.Rcheck/00check.log ${LOG_DIR}/check.log

.PHONY: build
build: ${PKGNAME}_${PKGVERS}.tar.gz
${PKGNAME}_${PKGVERS}.tar.gz: ${R_FILES} ${MAN_FILES} ${TESTS_FILES} ${VIGNETTE_FILES} NEWS.md README.md DESCRIPTION LICENSE ${LOG_DIR}/roxygen2.Rout ${LOG_DIR}/spell.log  ${LOG_DIR}/news.log 
	${R} --vanilla CMD build ../${PKGSRC}

${LOG_DIR}/news.log: DESCRIPTION NEWS.md
	${Rscript} --vanilla -e 'source(file.path("utils", "checks.R")); check_news()' > ${LOG_DIR}/news.log 2>&1 

.PHONY: spell
spell: ${LOG_DIR}/spell.log
${LOG_DIR}/spell.log: ${MAN_FILES} DESCRIPTION ${LOG_DIR}/roxygen2.Rout 
	${Rscript} --vanilla -e 'spell <- devtools::spell_check(); if (length(spell) > 0) {print(spell); warning("spell check failed")} ' > ${LOG_DIR}/spell.log 2>&1 

${LOG_DIR}/roxygen2.Rout: ${R_FILES}
	${R} --vanilla -e 'roxygen2::roxygenize(".")' > ${LOG_DIR}/roxygen2.Rout 2>&1 

README.md: README.Rmd 
	${Rscript} --vanilla -e 'knitr::knit("README.Rmd")'

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
