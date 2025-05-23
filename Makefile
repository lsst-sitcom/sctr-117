DOCTYPE = SCTR
NAMESPACE = PSE
PLAN = LVV-P138
DOCNUMBER = 117
DOCNAME = $(DOCTYPE)-$(DOCNUMBER)
DOCNAMEP = $(DOCNAME)-plan
TEX = $(filter-out $(wildcard *acronyms.tex) , $(wildcard *.tex))

export TEXMFHOME ?= lsst-texmf/texmf

# Version information extracted from git.
GITVERSION := $(shell git log -1 --date=short --pretty=%h)
GITDATE := $(shell git log -1 --date=short --pretty=%ad)
GITSTATUS := $(shell git status --porcelain)
ifneq "$(GITSTATUS)" ""
	GITDIRTY = -dirty
endif

all:  $(DOCNAME).pdf $(DOCNAMEP).pdf

%.pdf: %.tex meta.tex acronyms.tex
	xelatex $<
	bibtex $(basename $<)
	xelatex $<
	xelatex $<
	xelatex $<


.FORCE:

meta.tex: Makefile .FORCE
	rm -f $@
	touch $@
	printf '%% GENERATED FILE -- edit this in the Makefile\n' >>$@
	printf '\\newcommand{\\lsstDocType}{$(DOCTYPE)}\n' >>$@
	printf '\\newcommand{\\lsstDocNum}{$(DOCNUMBER)}\n' >>$@
	printf '\\newcommand{\\vcsRevision}{$(GITVERSION)$(GITDIRTY)}\n' >>$@
	printf '\\newcommand{\\vcsDate}{$(GITDATE)}\n' >>$@


# Almost none of the test runs have the "include in report" set to True so
# I enable includeall here - take it out if you start using the flag
generate: .FORCE
	docsteady --namespace $(NAMESPACE) generate-tpr --includeall True $(PLAN) $(DOCNAME).tex


#Traditional acronyms are better in this document
# remeber to add more TAGS like PMO or CAM to get corect acronyms and preferably
# do not commit acronyms.tex
acronyms.tex : ${TEX} myacronyms.txt skipacronyms.txt
	echo ${TEXMFHOME}
	python3 ${TEXMFHOME}/../bin/generateAcronyms.py -t "DM"    $(TEX)

myacronyms.txt :
	touch myacronyms.txt

skipacronyms.txt :
	touch skipacronyms.txt

clean :
	latexmk -c
	rm *.pdf *.nav *.bbl *.xdv *.snm
