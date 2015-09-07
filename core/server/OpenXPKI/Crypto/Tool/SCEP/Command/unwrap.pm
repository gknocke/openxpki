## OpenXPKI::Crypto::Tool::SCEP::Command::unwrap
## Written 2015 by Gideon Knocke for the OpenXPKI project
## (C) Copyright 20015 by The OpenXPKI Project
package OpenXPKI::Crypto::Tool::SCEP::Command::unwrap;

use strict;
use warnings;

use Class::Std;

use OpenXPKI::Debug;
use Crypt::LibSCEP;

my %pkcs7_of :ATTR;
my %engine_of  :ATTR;

sub START {
    my ($self, $ident, $arg_ref) = @_;
    $pkcs7_of{$ident} = $arg_ref->{PKCS7};
    $engine_of{$ident} = $arg_ref->{ENGINE};
}

sub get_result
{
    my $self = shift;
    my $ident = ident $self;
    # keyfile, signcert, password for keyfile
    if (! defined $engine_of{$ident}) {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_UNWRAP_NO_ENGINE',
        );
    }

    my $keyfile  = $engine_of{$ident}->get_keyfile();
    if (! defined $keyfile || $keyfile eq '') {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_UNWRAP_KEYFILE_MISSING',
        );
    }
    my $certfile = $engine_of{$ident}->get_certfile();
    if (! defined $certfile || $certfile eq '') {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_UNWRAP_CERTFILE_MISSING',
        );
    }
    my $pwd    = $engine_of{$ident}->get_passwd();

    my $cert;
    open(my $fh, '<', $certfile) or OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_UNWRAP_CANNOT_READ_CERT',
        );
    {
        local $/;
        $cert = <$fh>;
    }
    close($fh);

    my $key;
    open(my $fh, '<', $keyfile) or OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_UNWRAP_CANNOT_READ_KEY',
        );
    {
        local $/;
        $key = <$fh>;
    }
    close($fh);
    my $config = {passin=>"pass", passwd=>$pwd};
    my $pkcs7 = $pkcs7_of{$ident};
    my $scep_handle = Crypt::LibSCEP::unwrap($config, $pkcs7, $cert, $cert, $key);
    if(!$scep_handle) {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_UNWRAP_LIBSCEP_FAILED',
        );
    }
    return $scep_handle;


}

1;
__END__

=head1 Name

OpenXPKI::Crypto::Tool::SCEP::Command::unwrap - parses a pkiMessage

=head1 Description

This is used for creating a SCEP handle which contains every
information extracted from the pkiMessage.