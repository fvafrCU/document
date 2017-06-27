# inspired by https://raw.githubusercontent.com/yihui/knitr/master/Makefile
PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)
R_FILES := $(shell find R/ -type f)
MAN_FILES := $(shell find man/ -type f)
TESTS_FILES := $(shell find tests/ -type f | egrep  -E '(testthat|runit)')
VIGNETTES_FILES := $(shell find vignettes/ -type f)


temp_file := $(shell tempfile)
lintr_script := utils/lintr.R
LOG_DIR := log

R := R-devel
Rscript := Rscript-devel

all: dev_check dev_vignettes check_donttest utils craninstall

# devtools
dev_all: dev dev_vignettes


dev: dev_check dev_spell


dev_check_bare:
	rm ${temp_file} || true; \
		${Rscript} --vanilla -e 'devtools::check(cran = TRUE, check_version = TRUE, args = "--no-tests")' > ${temp_file} 2>&1; \
		grep -v ".*'/" ${temp_file} | grep -v ".*‘/" > ${LOG_DIR}/dev_check.Rout ;\
		grep "checking tests ... SKIPPED" ${LOG_DIR}/dev_check.Rout

dev_check_dont: 
	rm ${temp_file} || true; \
		${Rscript} --vanilla -e 'devtools::check(cran = TRUE, check_version = TRUE, args = "--run-donttest")' > ${temp_file} 2>&1; \
		grep -v ".*'/" ${temp_file} | grep -v ".*‘/" > ${LOG_DIR}/dev_check_dont.Rout ;\

dev_check: dev_test README.md
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

# R CMD 
craninstall: check_donttest
	${R} --vanilla CMD INSTALL  ${PKGNAME}_${PKGVERS}.tar.gz

check_donttest: ${PKGNAME}_${PKGVERS}.tar.gz
	export _R_CHECK_FORCE_SUGGESTS_=TRUE && \
		${R} --vanilla CMD check --as-cran --run-donttest \
		${PKGNAME}_${PKGVERS}.tar.gz && \
		cp ${PKGNAME}.Rcheck/00check.log log/check_donttest.log

install: check 
	${R} --vanilla CMD INSTALL  ${PKGNAME}_${PKGVERS}.tar.gz && \
        printf '===== have you run\n\tmake demo && ' && \
        printf 'make utils\n?!\n' 


.PHONY: check
check: ${LOG_DIR}/check.log
${LOG_DIR}/check.log: ${PKGNAME}_${PKGVERS}.tar.gz
	export _R_CHECK_FORCE_SUGGESTS_=TRUE && \
        ${R} --vanilla CMD check ${PKGNAME}_${PKGVERS}.tar.gz && \
		cp ${PKGNAME}.Rcheck/00check.log ${LOG_DIR}/check.log

# utils
.PHONY: utils
utils: cleanr lintr coverage 

.PHONY: runit
runit:
	cd ./tests/ && ${Rscript} --vanilla ./runit.R || printf "\nMaybe your installation is stale? \nTry\n\tmake install_bare\n\n"

.PHONY: coverage
coverage:
	${Rscript} --vanilla -e 'co <- covr::package_coverage(path = ".", function_exclusions = "\\.onLoad"); covr::zero_coverage(co); print(co)' > ${LOG_DIR}/covr.Rout 2>&1 


.PHONY: cleanr
cleanr:
	${Rscript} --vanilla -e 'cleanr::check_directory("R/",  max_num_arguments = 9, check_return = FALSE)'

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
${LOG_DIR}/news.log: DESCRIPTION NEWS.md
	${Rscript} --vanilla -e 'source(file.path("utils", "checks.R")); check_news()' > ${LOG_DIR}/news.log 2>&1 

.PHONY: spell
spell: ${LOG_DIR}/spell.log
${LOG_DIR}/spell.log: ${MAN_FILES} DESCRIPTION
	${Rscript} --vanilla -e 'spell <- devtools::spell_check(); if (length(spell) > 0) {print(spell); warning("spell check failed")} ' > ${LOG_DIR}/spell.log 2>&1 

.PHONY: build
build: ${PKGNAME}_${PKGVERS}.tar.gz
${PKGNAME}_${PKGVERS}.tar.gz: ${R_FILES} ${MAN_FILES} ${TESTS_FILES} ${VIGNETTE_FILES} NEWS.md README.md DESCRIPTION LICENSE ${LOG_DIR}/roxygen2.Rout 
	${R} --vanilla CMD build ../${PKGSRC}

${LOG_DIR}/roxygen2.Rout: ${R_FILES}
	${R} --vanilla -e 'roxygen2::roxygenize(".")' > ${LOG_DIR}/roxygen2.Rout 2>&1 

README.md: README.Rmd 
	${Rscript} --vanilla -e 'knitr::knit("README.Rmd")'

# visualize the Makefile
${LOG_DIR}/plot_make.png: Makefile
	make -Bnd | makefile2graph | dot -Tpng -o ${LOG_DIR}/plot_make.png
