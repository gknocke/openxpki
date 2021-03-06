# trunk/package/debian/core

OPENXPKI_SVN=../../../..
PACKAGE=libopenxpki-client-perl
PERLNAME=OpenXPKI-Client

default:
	make clean
	make changelog
	make openxpki-archive
	make debian-archive
	make source
	make package
	make source-clean

openxpki-archive:
	cd ${OPENXPKI_SVN}/trunk/clients/perl/OpenXPKI-Client; \
	perl Makefile.PL; \
	make dist; \
	mv $(PERLNAME)-*.tar.gz /tmp

debian-archive:
	## cd ${OPENXPKI_SVN}/trunk/package/
	tar -czf /tmp/openxpki-debian.tar.gz .

source:
	cd /tmp; \
	tar -xzf $(PERLNAME)-*.tar.gz; \
	cd $(PERLNAME)-*/; \
	mkdir debian; \
	cd debian; \
	tar -xzf /tmp/openxpki-debian.tar.gz;

package:
	cd /tmp/$(PERLNAME)-*/; \
	fakeroot dpkg-buildpackage || echo ignoring error - usually signing ...
	test -d ../deb/client_api || mkdir ../deb/client_api
	mv /tmp/$(PACKAGE)_* ../deb/client_api/

changelog::
	if [ ! -e changelog.org ]; then mv changelog changelog.org; fi
	echo -n $(PACKAGE) > changelog
	DATE=`date +'%Y%m%d'` && echo \ \($$DATE\) unstable\; urgency=low >> changelog
	echo >> changelog
	echo "  * Daily build." >> changelog
	echo >> changelog
	echo " -- Scott T Hardin <scotty@hnsc.de> " `date --rfc-2822` >> changelog

source-clean:
	rm -rf /tmp/$(PERLNAME)-*
	rm -f /tmp/openxpki-debian.tar.gz

clean:	source-clean
	if [ -e changelog.org ]; then mv changelog.org changelog; fi
	rm -f *.dsc *.dsc.asc *.tar.gz ../deb/client_api/* *.changes
