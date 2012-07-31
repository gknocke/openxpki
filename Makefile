# Makefile
#
# This makefile is an entry point for continuous integration testing systems.
# It's oriented towards Travis-CI, but is certainly adaptable to other build
# and test systems.
#
# For normal package builds, see the documentation.
#
# NOTE: The test targets make some general assumptions on the build/test
# environment. Among these assumptions are:
#
# - perlbrew is used for a local perl installation
# - cpanm is used for CPAN prerequisites

# Ubuntu uses dash, which sucks when using '.' to source an RC file.
SHELL=/bin/bash

TESTLOGDIR=logs
TESTLOG=$(TESTLOGDIR)/test-$(shell date "+%Y-%m-%d-%H%M").log

default:
	@echo
	@echo "Sorry, but this Makefile is for continuous integration testing."
	@echo "For normal package build, see the documentation."

PERLBREW_RC := $(HOME)/perl5/perlbrew/etc/bashrc
# Determine the latest version of Perl available via perlbrew
PERLBREW_LATEST := $(shell echo ". $(PERLBREW_RC) && perlbrew available" | bash | head -n 1)

# Travis-CI provides perlbrew already, but this target may be used on other
# systems to get perlbrew installed.
perlbrew:
	curl -kL http://install.perlbrew.pl | bash
	. $(PERLBREW_RC) && perlbrew install $(PERLBREW_LATEST)
	. $(PERLBREW_RC) && perlbrew switch $(PERLBREW_LATEST)
	. $(PERLBREW_RC) && curl -L http://cpanmin.us | perl - App::cpanminus

# Travis-CI will call the command 'cpanm --installdeps --notest .' to update
# the build prereqs for the project. This 'cpanm' target may be used on other
# systems to install the dependencies. Note: it sources the perlbrew bashrc
# just in case perlbrew was installed using the above target and is not 
# in the current user environment.
cpanm:
	. $(PERLBREW_RC) && cpanm --installdeps --notest .

.PHONY: clean-core
clean-core:
	(cd trunk/perl-modules/core/trunk && \
		rm -rf Makefile OpenXPKI.bs OpenXPKI.c OpenXPKI.o blib \
		pm_to_blib \
	)

# Travis-CI uses 'make test' as a generic entry point for Perl projects when
# it can't find Build.PL or Makefile.PL. This seems like a good spot for us
# to be called. So, 'yes', this is where Travis-CI actually starts the tests.
test: clean-core
	mkdir -p $(TESTLOGDIR)
	. $(PERLBREW_RC) && \
		(cd trunk/perl-modules/core/trunk && perl Makefile.PL && make test) 2>&1 | \
		tee $(TESTLOG)
