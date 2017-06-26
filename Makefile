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
HEADER_SUFFIXES :=.h .hpp
### DIRECTORIES
SRCDIR :=src
INCDIR :=include
OBJDIR :=build
BINDIR :=bin
TSTDIR :=tests
DEPDIR :=.deps
### PROGRAM-RELATED VARIABLES
# Files
MAINFILES :=src/perf.cpp
BINARIES  :=$(BINDIR)/execute_me
# Compiler & linker flags
CXXFLAGS :=-std=c++14 -Wall -fopenmp -O3
LDFLAGS  :=
LDLIBS   :=
INCLUDE  :=-I$(INCDIR)
### TESTS-RELATED VARIABLES
# Files
TMAINFILES :=$(wildcard $(TSTDIR)/*.cpp)
TBINARIES  :=$(patsubst $(TSTDIR)/%.cpp,$(BINDIR)/%,$(TMAINFILES))
# Compiler & linker flags
TCXXFLAGS :=
TLDFLAGS  :=-lgtest_main -pthread
TLDLIBS   :=
TINCLUDE  :=
### MAKEFILE CONTROL VARIABLES
# Debug flag, if != 0 deactivates all supressed echoing
DEBUG :=0
############################# AUTOMATIC VARIABLES #############################
### PROGRAM-RELATED VARIABLES
MAINDEPS :=$(patsubst %.cpp,$(DEPDIR)/%.mk,$(MAINFILES))
SOURCES  :=$(shell find $(SRCDIR) -name '*.cpp' 2> /dev/null)
OBJECTS  :=$(patsubst %.cpp,$(OBJDIR)/%.o,$(SOURCES))
DEPS     :=$(patsubst %.cpp,$(DEPDIR)/%.d,$(SOURCES))
CALLS    :=$(notdir $(BINARIES))
### TESTS-RELATED VARIABLES
TMAINDEPS :=$(patsubst %.cpp,$(DEPDIR)/%.mk,$(TMAINFILES))
TSOURCES  :=$(shell find $(TSTDIR) -name '*.cpp' 2> /dev/null)
TOBJECTS  :=$(patsubst %.cpp,$(OBJDIR)/%.o,$(TSOURCES))
TDEPS     :=$(patsubst %.cpp,$(DEPDIR)/%.d,$(TSOURCES))
TCALLS    :=$(notdir $(TBINARIES))
### MISCELLANEOUS
# Command to print status messages
MPRINT  :=@echo
# Autogenerated directories
MAKEDIR :=$(BINDIR) $(SRCDIR) $(INCDIR)
# List with all suffixes for headers and sources
ALLSUFFIXES  :=$(HEADER_SUFFIXES) .cpp
# Creation of variables associating each main file with a program
MAINEXECVARS :=$(basename $(notdir $(MAINFILES) $(TMAINFILES)))
MAINEXECVARS :=$(addsuffix _EXEC:=,$(MAINEXECVARS))
MAINEXECVARS :=$(join $(MAINEXECVARS), $(BINARIES) $(TBINARIES))
$(foreach var,$(MAINEXECVARS),$(eval $(var)))
# Multiline variable with all commands to generate .mk files for each main file
# Arguments: file to be written, file to read of, target file, objects variable
# name, dependencies variable name
define make_main_deps
	$(eval $(4):=$(filter $(addprefix %,$(ALLSUFFIXES)),$(shell cat $(2))))
	$(eval $(4):=$(basename $($(4))))
	$(eval $(4):=$(patsubst $(INCDIR)/%,$(SRCDIR)/%,$($(4))))
	$(eval $(4):=$(patsubst %,$(OBJDIR)/%.o,$($(4))))
	$(eval $(4):=$(filter $($(4)),$(OBJECTS) $(TOBJECTS)))
	$(eval $(5):=$(patsubst $(OBJDIR)/%.o,$(DEPDIR)/%.d,$($(4))))
	$(file > $(1),$(4) :=$($(4)))
	$(file >> $(1),$(3): $$($(4)))
	$(file >> $(1),-include $($(5)))
endef
# If DEBUG is not active (i.e, equals 1), set supressing character (@)
ifeq ($(DEBUG),0)
SILENT :=@
endif

.PHONY: all makedir clean distclean tests $(TCALLS)

################################# MAIN RULES ##################################
all: makedir $(BINARIES)

$(foreach target,$(CALLS) $(TCALLS),$(eval $(target): $(BINDIR)/$(target)))

$(BINARIES) $(TBINARIES): | $(BINDIR)
	$(MPRINT) "[linking] $@"
	$(SILENT) $(CXX) $(CXXFLAGS) $(LDFLAGS) $(INCLUDE) \
	$($(@F)_OBJS) $(LDLIBS) -o $@

$(OBJDIR)/%.o: %.cpp
	$(MPRINT) "[  $(CXX)  ] $< -> .o"
	$(SILENT) mkdir -p $(OBJDIR)/$(*D)
	$(SILENT) $(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

$(DEPDIR)/%.d: %.cpp
	$(MPRINT) "[makedep] $< -> .d"
	$(SILENT) mkdir -p $(DEPDIR)/$(*D)
	$(SILENT) $(CXX) $(CXXFLAGS) $(INCLUDE) -MM -MP -MG \
	-MT "$(OBJDIR)/$*.o $@" -MF "$@" $<

$(MAINDEPS) $(TMAINDEPS): %.mk: %.d
	$(MPRINT) "[makedep] $< -> .mk"
	$(SILENT) mkdir -p $(*D)
	$(eval OBJS_LABEL=$(notdir $($(*F)_EXEC))_OBJS)
	$(eval DEPS_LABEL=$(notdir $($(*F)_EXEC))_DEPS)
	$(call make_main_deps,$@,$^,$($(*F)_EXEC),$(OBJS_LABEL),$(DEPS_LABEL))

makedir: | $(MAKEDIR)

$(MAKEDIR):
	$(MPRINT) "[ mkdir ] Creating directory '$@'"
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
  -include $(MAINDEPS)
else
  ifneq ($(filter tests $(TCALLS) $(TBINARIES),$(MAKECMDGOALS)),)
    -include $(TMAINDEPS)
  endif
endif
