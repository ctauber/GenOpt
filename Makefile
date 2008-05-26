SHELL=/bin/sh
######################################################################
# GenOpt Makefile.
# This file is only needed by developers. 
# It can be used to compile, document and run unit tests
# from a bash shell.
#
# MWetter@lbl.gov                                           2008-05-08
######################################################################
UNAME = $(shell uname)

# List of source code files
SRC=`find genopt -name '*.java'`
# List of class files
CLAFIL=`find src -name '*.class'`
CLAFILGO=`find genopt -name '*.class'`
# List of run time files
RUNFIL=`find example \( -name 'OutputListing*' -or -name 'GenOpt.log' \
        -or -name 'eplusout.*' -or -name '*.eso' -or -name '*.audit' \
        -or -name '*.err' -or -name '*.eio' -or -name '*.end' -or -name '*.csv' \
        -or -name '*.svg' -or -name '*.bnd' -or -name '*.mtd' \
        -or -name '*.audit' \)`
RUNDIR=`find example \( -name 'Output' \)`

# Directory where distributable will be copied
DISDIR=dist

# List of directories with example files
EXADIR=$(shell find example/quad -maxdepth 1 \( -type d -not -name '.svn' \) )
# Root directory of GenOpt
ROODIR=$(shell pwd)

# Initialization file for examples


ifeq ($(UNAME), Darwin)
INIFIL=optMacOSX.ini
endif
ifeq ($(UNAME), Linux)
INIFIL=optLinux.ini
endif
ifeq ($(UNAME), CYGWIN*)
INIFIL=optWinXP.ini
endif


# Executable for izpack. IzPack is used
# to create the GenOpt installation software
ifeq ($(UNAME), Darwin)
IZPACK=/Applications/IzPack/bin/compile
else
IZPACK=izpack
endif

export genopt-version=2.1.0
### Targets of Makefile ###########################
### Compiles the GenOpt source code and the JavaDoc 
all: doc jar

### Compiles the GenOpt source code
prog:
	(cd src; javac -Xlint:unchecked $(SRC))
	@echo "==== Made program"

### Makes the jar file
jar: prog
	(cd src; jar cfm ../genopt.jar genopt/Manifest.txt $(CLAFILGO) genopt/img/* ../legal.html)
	jar -i genopt.jar 
	@echo "==== Made jar file"

### Deletes autogenerated files
clean:
	@if [ "$(CLAFIL)" != "" ]; then rm -v $(CLAFIL); fi
	@if [ "$(RUNFIL)"    != "" ]; then rm -v $(RUNFIL); fi
	@if [ "$(RUNDIR)"    != "" ]; then rm -r $(RUNDIR); fi
	@echo "==== Deleted autogenerated files"

### generates JavaDoc html files
doc:
	rm -f documentation/jdoc/*.html documentation/jdoc/package-list
	rm -rf documentation/jdoc/genopt/*
	(cd src; javadoc -breakiterator -private -author -version \
	-windowtitle "GenOpt Code Documentation" \
	-stylesheetfile ../documentation/jdoc/jstyle.css \
	-bottom "<DIV CLASS="FOOTER"> <P> <CENTER> <A HREF="index.html" \
	TARGET=_top>GenOpt</A> | <A HREF="http://simulationresearch.lbl.gov" \
	TARGET=_top>LBL SRG</A> | <A HREF="http://www.lbl.gov" \
	TARGET=_top>LBL</A> </CENTER> <HR WIDTH="100%"> \
	<BR> Contact: <A HREF="mailto:MWetter@lbl.gov">MWetter@lbl.gov</A> </DIV>" -d ../documentation/jdoc $(SRC))
	@echo "==== Made documentation"

### unit tests
unitTest:
	@for x in $(EXADIR); do \
	    cd $(ROODIR); \
	    echo "++++ $$x"; \
	    if [ -f $$x/${INIFIL} ]; then \
	       	java -ea -classpath genopt.jar genopt.GenOpt $$x/${INIFIL}; \
		tesNam=`echo $$x | sed 's|/|-|g'`; \
		sed 1,19d $$x/OutputListingAll.txt | md5sum > unitTestResults/$$tesNam.md5sum; \
	        if [ "$$?" != "0" ]; then \
	            echo "*** Error: Unit test failed for $$x/${INIFIL}"; \
	            exit 1; fi; \
	    else \
	          echo "*** Nothing to run in $$x"; \
	    fi; \
	done; \

dist:   prog doc jar 
	rm -f $(DISDIR)/genopt-install.jar
	cd install; \
	$(IZPACK) install.xml -b . -o genopt-install.jar -k standard; \
	mv genopt-install.jar ../$(DISDIR); 
	@echo "==== Made distribution in $(DISDIR)/genopt-install.jar";
