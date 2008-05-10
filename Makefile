SHELL=/bin/sh
######################################################################
# GenOpt makefile to compile, document and run unit tests.
#
# MWetter@lbl.gov                                           2008-05-08
######################################################################

# List of source code files
SRC=`find genopt -name '*.java'`
# List of class files
CLA=`find genopt -name '*.class'`

# List of example files used for unit test
EXAFIL=$(shell find ./example -name optLinux.ini)
# List of directories with example files
EXADIR=$(shell find example -type d)
# Root directory of GenOpt
ROODIR=$(shell pwd)


### Compiles the GenOpt source code and the JavaDoc 
all: doc prog

### Compiles the GenOpt source code
prog:
	javac -Xlint:unchecked $(SRC)

### Deletes autogenerated files
clean:
	rm $(CLA)


### generates JavaDoc html files
doc:
	rm -f jdoc/*.html jdoc/package-list
	rm -rf jdoc/genopt/*
	javadoc -breakiterator -private -author -version \
	-windowtitle "GenOpt Code Documentation" \
	-stylesheetfile jdoc/jstyle.css \
	-bottom "<DIV CLASS="FOOTER"> <P> <CENTER> <A HREF="index.html" \
	TARGET=_top>GenOpt</A> | <A HREF="http://simulationresearch.lbl.gov" \
	TARGET=_top>LBL SRG</A> | <A HREF="http://www.lbl.gov" \
	TARGET=_top>LBL</A> </CENTER> <HR WIDTH="100%"> \
	<BR> Contact: <A HREF="mailto:MWetter@lbl.gov">MWetter@lbl.gov</A> </DIV>" -d jdoc $(SRC)

### unit tests
unitTest:
	echo $(EXADIR)
	@for x in $(EXADIR); do \
	    cd $(ROODIR); \
	    echo "++++ $(ROODIR)"; \
	    if [ -f $$x/optLinux.ini ]; then \
	       	cd $$x && java -ea genopt.GenOpt optLinux.ini; \
	        if [ "$$?" != "0" ]; then \
	            echo "*** Error: Unit test failed for $$x/optLinux.ini"; \
	            exit 1; fi; \
	    else \
	          echo "*** Nothing to run in $$x"; \
	    fi; \
	done; \
