#
#   - Test::Pod::Coverage -
#   This spec file was automatically generated by cpan2rpm [ver: 2.027]
#   The following arguments were used:
#       --spec-only --version=1.08 '--author=Andy Lester' Test-Pod-Coverage-1.08.tar.gz
#   For more information on cpan2rpm please visit: http://perl.arix.com/
#

%define pkgname Test-Pod-Coverage
%define filelist %{pkgname}-%{version}-filelist
%define NVR %{pkgname}-%{version}-%{release}
%define maketest 1

name:      perl-Test-Pod-Coverage
summary:   Test-Pod-Coverage - Check for pod coverage in your distribution
version:   1.08
release:   1
vendor:    Andy Lester
packager:  Arix International <cpan2rpm@arix.com>
license:   Artistic
group:     Applications/CPAN
url:       http://www.cpan.org
buildroot: %{_tmppath}/%{name}-%{version}-%(id -u -n)
buildarch: noarch
prefix:    %(echo %{_prefix})
source:    Test-Pod-Coverage-1.08.tar.gz

%description
Checks for POD coverage in files for your distribution.

    use Test::Pod::Coverage tests=>1;
    pod_coverage_ok( "Foo::Bar", "Foo::Bar is covered" );

Can also be called with Pod::Coverage parms.

    use Test::Pod::Coverage tests=>1;
    pod_coverage_ok(
        "Foo::Bar",
        { also_private => [ qr/^[A-Z_]+$/ ], },
        "Foo::Bar, with all-caps functions as privates",
    );

The Pod::Coverage parms are also useful for subclasses that don't
re-document the parent class's methods.  Here's an example from
Mail::SRS.

    pod_coverage_ok( "Mail::SRS" ); # No exceptions

    # Define the three overridden methods.
    my $trustme = { trustme => [qr/^(new|parse|compile)$/] };
    pod_coverage_ok( "Mail::SRS::DB", $trustme );
    pod_coverage_ok( "Mail::SRS::Guarded", $trustme );
    pod_coverage_ok( "Mail::SRS::Reversable", $trustme );
    pod_coverage_ok( "Mail::SRS::Shortcut", $trustme );

Alternately, you could use Pod::Coverage::CountParents, which always allows
a subclass to reimplement its parents' methods without redocumenting them.  For
example:

    my $trustparents = { coverage_class => 'Pod::Coverage::CountParents' };
    pod_coverage_ok( "IO::Handle::Frayed", $trustparents );

(The "coverage_class" parameter is not passed to the coverage class with other
parameters.)

If you want POD coverage for your module, but don't want to make
Test::Pod::Coverage a prerequisite for installing, create the following
as your t/pod-coverage.t file:

    use Test::More;
    eval "use Test::Pod::Coverage";
    plan skip_all => "Test::Pod::Coverage required for testing pod coverage" if $@;

    plan tests => 1;
    pod_coverage_ok( "Pod::Master::Html");

Finally, Module authors can include the following in a t/pod-coverage.t
file and have "Test::Pod::Coverage" automatically find and check all
modules in the module distribution:

    use Test::More;
    eval "use Test::Pod::Coverage 1.00";
    plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage" if $@;
    all_pod_coverage_ok();

#
# This package was generated automatically with the cpan2rpm
# utility.  To get this software or for more information
# please visit: http://perl.arix.com/
#

%prep
%setup -q -n %{pkgname}-%{version} 
chmod -R u+w %{_builddir}/%{pkgname}-%{version}

%build
grep -rsl '^#!.*perl' . |
grep -v '.bak$' |xargs --no-run-if-empty \
%__perl -MExtUtils::MakeMaker -e 'MY->fixin(@ARGV)'
CFLAGS="$RPM_OPT_FLAGS"
%{__perl} Makefile.PL `%{__perl} -MExtUtils::MakeMaker -e ' print qq|PREFIX=%{buildroot}%{_prefix}| if \$ExtUtils::MakeMaker::VERSION =~ /5\.9[1-6]|6\.0[0-5]/ '`
%{__make} 
%if %maketest
%{__make} test
%endif

%install
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%{makeinstall} `%{__perl} -MExtUtils::MakeMaker -e ' print \$ExtUtils::MakeMaker::VERSION <= 6.05 ? qq|PREFIX=%{buildroot}%{_prefix}| : qq|DESTDIR=%{buildroot}| '`

cmd=/usr/share/spec-helper/compress_files
[ -x $cmd ] || cmd=/usr/lib/rpm/brp-compress
[ -x $cmd ] && $cmd

# SuSE Linux
if [ -e /etc/SuSE-release -o -e /etc/UnitedLinux-release ]
then
    %{__mkdir_p} %{buildroot}/var/adm/perl-modules
    %{__cat} `find %{buildroot} -name "perllocal.pod"`  \
        | %{__sed} -e s+%{buildroot}++g                 \
        > %{buildroot}/var/adm/perl-modules/%{name}
fi

# remove special files
find %{buildroot} -name "perllocal.pod" \
    -o -name ".packlist"                \
    -o -name "*.bs"                     \
    |xargs -i rm -f {}

# no empty directories
find %{buildroot}%{_prefix}             \
    -type d -depth                      \
    -exec rmdir {} \; 2>/dev/null

%{__perl} -MFile::Find -le '
    find({ wanted => \&wanted, no_chdir => 1}, "%{buildroot}");
    print "%doc  Changes";
    for my $x (sort @dirs, @files) {
        push @ret, $x unless indirs($x);
        }
    print join "\n", sort @ret;

    sub wanted {
        return if /auto$/;

        local $_ = $File::Find::name;
        my $f = $_; s|^\Q%{buildroot}\E||;
        return unless length;
        return $files[@files] = $_ if -f $f;

        $d = $_;
        /\Q$d\E/ && return for reverse sort @INC;
        $d =~ /\Q$_\E/ && return
            for qw|/etc %_prefix/man %_prefix/bin %_prefix/share|;

        $dirs[@dirs] = $_;
        }

    sub indirs {
        my $x = shift;
        $x =~ /^\Q$_\E\// && $x ne $_ && return 1 for @dirs;
        }
    ' > %filelist

[ -z %filelist ] && {
    echo "ERROR: empty %files listing"
    exit -1
    }

%clean
[ "%{buildroot}" != "/" ] && rm -rf %{buildroot}

%files -f %filelist
%defattr(-,root,root)

%changelog
* Thu Nov 23 2006 root@dca02
- Initial build.