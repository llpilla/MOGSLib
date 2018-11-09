###############################################################################
####################### <github.com/aszdrick/magefile> ########################
############################ <aszdrick@gmail.com> #############################
###############################################################################

# Copyright (c) 2017 Marleson Graf

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

############################## PROJECT VARIABLES ##############################
### SUPPORTED SUFFIXES
HDRSUFFIXES :=h hpp
### DIRECTORIES
SRCDIR :=src
INCDIR :=include
OBJDIR :=build
BINDIR :=bin
TSTDIR :=tests
DEPDIR :=.deps
### PROGRAM-RELATED VARIABLES
# Files
MAINFILES :=src/load_oblivious.cpp
BINARIES  :=$(BINDIR)/execute_me
# Compiler & linker flags
CXXFLAGS :=-std=c++14 -Wall -O3
LDFLAGS  :=
LDLIBS   :=
INCLUDE  :=$(foreach d, $(INCDIR), -I$d)
#-I$(INCDIR)
### TESTS-RELATED VARIABLES
# Files
TMAINFILES :=$(shell find $(TSTDIR) -name '*.cpp' 2> /dev/null)
TBINARIES  :=$(patsubst $(TSTDIR)/%.cpp,$(BINDIR)/%,$(TMAINFILES))
# Compiler & linker flags
TCXXFLAGS :=
TLDFLAGS  :=-L/usr/lib
TLDLIBS   :=-lgtest -lgtest_main -pthread
TINCLUDE  :=
### MAKEFILE CONTROL VARIABLES
# Debug flag, if != 0 deactivates all supressed echoing
DEBUG :=0
############################# AUTOMATIC VARIABLES #############################
### PROGRAM-RELATED VARIABLES
MAINDEPS  :=$(patsubst %.cpp,$(DEPDIR)/%.d,$(MAINFILES))
CALLS     :=$(notdir $(BINARIES))
### TESTS-RELATED VARIABLES
TMAINDEPS :=$(patsubst %.cpp,$(DEPDIR)/%.d,$(TMAINFILES))
TCALLS    :=$(notdir $(TBINARIES))
# AUTOGENERATED DIRECTORIES
AUTODIR   :=$(BINDIR) $(SRCDIR) $(INCDIR)
### MISCELLANEOUS
empty :=
space :=$(empty) $(empty)
# No operation of shell script
nop   :=:
# Command to print status messages
INFO  :=@echo
# List with all suffixes for headers and sources
ALLSUFFIXES  :=$(HDRSUFFIXES) cpp
ALLMAINFILES :=$(MAINFILES) $(TMAINFILES)
# Creation of variables associating each main file with a program
MAINEXECVARS :=$(basename $(MAINFILES) $(TMAINFILES))
MAINEXECVARS :=$(addsuffix _EXEC:=,$(MAINEXECVARS))
MAINEXECVARS :=$(join $(MAINEXECVARS), $(BINARIES) $(TBINARIES))
$(foreach var,$(MAINEXECVARS),$(eval $(var)))
SOURCES =$(shell find $(SRCDIR) -name '*.cpp' 2> /dev/null)
SOURCES +=$(shell find $(TSTDIR) -name '*.cpp' 2> /dev/null)
OBJECTS :=$(eval OBJECTS:=$(patsubst %.cpp,$(OBJDIR)/%.o,$(SOURCES)))$(OBJECTS)
DEPS    :=$(shell find $(DEPDIR) -name *.d 2> /dev/null)
# Arguments: target string, output name, input name
makedep = $(CXX) $(CXXFLAGS) $(INCLUDE) -MM -MG -MT $(1) -MF "$(2)" $(3)
# For all three *_make_deps the arguments are:
# file to be written, target file, objects variable name
define base_make_deps
	$(info [makedep] $(2) -> .d)
	$(shell mkdir -p $(dir $(1)))
	$(eval $(3)_OBJ:=$(patsubst %.cpp,$(OBJDIR)/%.o,$(2)))
	$(shell $(call makedep,"$($(3)_OBJ) $(1)",$(1),$(2)))
	$(eval $(3)_CHAIN:=$(shell cat $(1)))
	$(eval $(3)_CHAIN:=$(filter $(addprefix %.,$(HDRSUFFIXES)),$($(3)_CHAIN)))
	$(eval $(3)_CHAIN:=$(patsubst $(INCDIR)/%,$(SRCDIR)/%,$($(3)_CHAIN)))
	$(eval $(3)_CHAIN:=$(patsubst %,$(OBJDIR)/%.o,$(basename $($(3)_CHAIN))))
	$(eval $(3)_CHAIN:=$(filter $($(3)_CHAIN),$(OBJECTS)))
	$(eval $(3)_CHAIN:=$(filter-out $($(3)_OBJ),$($(3)_CHAIN)))
	$(eval STEM_CHAIN:=$(patsubst $(OBJDIR)/%.o,%,$($(3)_CHAIN)))
	$(eval $(3)_CHAIN:=$(patsubst $(OBJDIR)/%.o,%_CHAIN,$($(3)_CHAIN)))
	$(eval DEPS+=$(1))
	$(file >> $(1),-$(1): | $(patsubst %,$(DEPDIR)/%.d,$(STEM_CHAIN)))
	$(foreach d,$(STEM_CHAIN),$(if $(filter-out $(DEPS),$(DEPDIR)/$(d).d),
		$(call chained_make_deps,$(DEPDIR)/$(d).d,$(d).cpp,$(d))))
endef
# make_deps directed to (other than main) files
define chained_make_deps
	$(call base_make_deps,$(1),$(2),$(3))
	$(file >> $(1),$(3)_CHAIN =$$(eval $(3)_CHAIN:=$($(3)_OBJ)\
	 $($(3)_CHAIN))$$($(3)_CHAIN))
endef
# make_deps directed to main files
define main_make_deps
	$(call base_make_deps,$(1),$(2),$(3))
	$(file >> $(1),$(3)_OBJS =$$(eval RET:=)$$(eval $(3)_OBJS:=$($(3)_OBJ)\
	 $$(call expand_chain,$($(3)_CHAIN))$$(RET))$$($(3)_OBJS))
	$(file >> $(1),$(3): $$($(3)_OBJS))
endef
# Receives a *_CHAIN list to expand
# *_CHAIN list value: *.o [other *_CHAIN lists]
define expand_chain
	$(foreach list,$(1),\
		$(eval RG1:=$(firstword $($(list))))\
		$(if $(filter-out $(RET),$(RG1)),\
			$(eval RET+=$(RG1))\
			$(call expand_chain,$(filter-out $(RG1),$($(list))))))
endef
# If DEBUG is not active (i.e, equals 1), set supressing character (@)
ifeq ($(DEBUG),0)
SILENT :=@
endif

.PHONY: all makedir clean distclean tests $(CALLS) $(TCALLS) nothing

################################# MAIN RULES ##################################
all: makedir $(BINARIES)

$(CALLS) $(TCALLS): %: $(BINDIR)/%

$(BINARIES) $(TBINARIES):
	$(INFO)   "[linking] $@"
	$(SILENT) mkdir -p $(dir $@)
	$(SILENT) $(CXX) $(CXXFLAGS) $(LDFLAGS) $(INCLUDE) $^ $(LDLIBS) -o $@

$(OBJDIR)/%.o: %.cpp
	$(INFO)   "[  $(CXX)  ] $< -> .o"
	$(SILENT) mkdir -p $(OBJDIR)/$(*D)
	$(SILENT) $(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

$(MAINDEPS) $(TMAINDEPS): $(DEPDIR)/%.d: %.cpp
	$(SILENT) $(nop) $(call main_make_deps,$@,$<,$($*_EXEC))

$(DEPDIR)/%.d: %.cpp
	$(SILENT) $(nop) $(call chained_make_deps,$@,$<,$*)

makedir: | $(AUTODIR)

$(AUTODIR):
	$(INFO)   "[ mkdir ] Creating directory '$@'"
	$(SILENT) mkdir -p $@

################################ TESTS RULES ##################################
tests: makedir $(TBINARIES)

$(TBINARIES): LDLIBS +=$(TLDLIBS)

$(TBINARIES): LDFLAGS +=$(TLDFLAGS)

$(OBJDIR)/$(TSTDIR)/%.o: CXXFLAGS +=$(TCXXFLAGS)

$(OBJDIR)/$(TSTDIR)/%.o: INCLUDE +=$(TINCLUDE)

################################ CLEAN RULES ##################################
# Only remove object files
clean:
	$(SILENT) $(RM) -r $(OBJDIR)
	$(SILENT) $(RM) -r $(BINDIR)

# Remove object, binary and dependency files
distclean: clean
	$(SILENT) $(RM) -r $(DEPDIR)

################################ PREREQUISITES ################################
# Do not include list of dependencies with clean rules
ifeq ($(filter-out all $(CALLS) $(BINARIES),$(MAKECMDGOALS)),)
  -include $(filter-out $(MAINDEPS) $(TMAINDEPS),$(DEPS))
  -include $(MAINDEPS)
else
  ifeq ($(filter-out tests $(TCALLS) $(TBINARIES),$(MAKECMDGOALS)),)
    -include $(filter-out $(MAINDEPS) $(TMAINDEPS),$(DEPS))
    -include $(TMAINDEPS)
  endif
endif
