## OpenXPKI::Crypto::Tool::SCEP::Command::get_pkcs10
## Written 2015 by Gideon Knocke for the OpenXPKI project
## (C) Copyright 20015 by The OpenXPKI Project
package OpenXPKI::Crypto::Tool::SCEP::Command::get_pkcs10;

use strict;
use warnings;

use Class::Std;

use OpenXPKI::Debug;
use Crypt::LibSCEP;

my %pkcs7_of   :ATTR;

sub START {
    my ($self, $ident, $arg_ref) = @_;
    $pkcs7_of {$ident} = $arg_ref->{PKCS7};
}

sub get_result
{
    my $self = shift;
    my $ident = ident $self;   

    my $csr = Crypt::LibSCEP::get_pkcs10($pkcs7_of{$ident});
    if(!$csr) {
        OpenXPKI::Exception->throw(
                message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_GET_PKCS10_LIBSCEP_FAILED',
            );
    }
    return $csr;
}

1;
__END__

=head1 Name

OpenXPKI::Crypto::Tool::SCEP::Command::get_pkcs10

=head1 Description

This function takes a SCEP handle and returns the
certificate signing request from it