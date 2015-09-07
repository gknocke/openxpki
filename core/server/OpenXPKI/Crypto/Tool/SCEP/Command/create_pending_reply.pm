## OpenXPKI::Crypto::Tool::SCEP::Command::create_pending_reply
## Written 2015 by Gideon Knocke for the OpenXPKI project
## (C) Copyright 20015 by The OpenXPKI Project
package OpenXPKI::Crypto::Tool::SCEP::Command::create_pending_reply;

use strict;
use warnings;

use Class::Std;

use OpenXPKI::Debug;
use Crypt::LibSCEP;

my %pkcs7_of   :ATTR;
my %engine_of  :ATTR;
my %hash_alg_of  :ATTR;

sub START {
    my ($self, $ident, $arg_ref) = @_;

    $engine_of{$ident} = $arg_ref->{ENGINE};
    $pkcs7_of {$ident} = $arg_ref->{PKCS7};
    $hash_alg_of {$ident} = $arg_ref->{HASH_ALG};
}

sub get_result
{
    my $self = shift;
    my $ident = ident $self;

    if (! defined $engine_of{$ident}) {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_CREATE_PENDING_REPLY_NO_ENGINE',
        );
    }
    ##! 64: 'engine: ' . Dumper($engine_of{$ident})
    my $keyfile  = $engine_of{$ident}->get_keyfile();
    if (! defined $keyfile || $keyfile eq '') {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_CREATE_PENDING_REPLY_KEYFILE_MISSING',
        );
    }
    my $certfile = $engine_of{$ident}->get_certfile();
    if (! defined $certfile || $certfile eq '') {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_CREATE_PENDING_REPLY_CERTFILE_MISSING',
        );
    }
    my $pwd    = $engine_of{$ident}->get_passwd();

    my $cert;
    open(my $fh, '<', $certfile) or OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_CREATE_PENDING_REPLY_CANNOT_READ_CERT',
        );
    {
        local $/;
        $cert = <$fh>;
    }
    close($fh);

    my $key;
    open(my $fh, '<', $keyfile) or OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_CREATE_PENDING_REPLY_CANNOT_READ_KEY',
        );
    {
        local $/;
        $key = <$fh>;
    }
    close($fh);


    my $sigalg = $hash_alg_of{$ident};
    my $pwd    = $engine_of{$ident}->get_passwd();
    my $transid = Crypt::LibSCEP::get_transaction_id($pkcs7_of{$ident});
    if (!$transid) {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_CREATE_PENDING_REPLY_LIBSCEP_CANNOT_GET_TRANS_ID',
        );
    }
    my $senderNonce = Crypt::LibSCEP::get_senderNonce($pkcs7_of{$ident});
        if (!$senderNonce) {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_CREATE_PENDING_REPLY_LIBSCEP_CANNOT_GET_SENDERNONCE',
        );
    }
    my $config = {passin=>"pass", passwd=>$pwd, sigalg=>$sigalg};
    my $pending_reply = Crypt::LibSCEP::create_pending_reply_wop7($config, $key, $cert, $transid, $senderNonce);
        if (!$pending_reply) {
        OpenXPKI::Exception->throw(
            message => 'I18N_OPENXPKI_CRYPTO_TOOL_SCEP_COMMAND_CREATE_PENDING_REPLY_LIBSCEP_CANNOT_SCEP_ERROR',
        );
    }
    #PEM TO DER
    $pending_reply =~ s/\n?\z/\n/;
    $pending_reply =~ s/^(?:.*\n){1,1}//;
    $pending_reply =~ s/(?:.*\n){1,1}\z//;
    use MIME::Base64;
    return decode_base64($pending_reply);
}


1;
__END__
