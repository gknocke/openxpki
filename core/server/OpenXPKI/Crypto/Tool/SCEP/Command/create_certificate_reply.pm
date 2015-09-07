## OpenXPKI::Crypto::Tool::SCEP::Command::create_certificate_reply
## Written 2015 by Gideon Knocke for the OpenXPKI project
## (C) Copyright 20015 by The OpenXPKI Project
package OpenXPKI::Crypto::Tool::SCEP::Command::create_certificate_reply;

use strict;
use warnings;

use Class::Std;

use OpenXPKI::Debug;
use Crypt::LibSCEP;

my %pkcs7_of   :ATTR;
my %cert_of    :ATTR;
my %engine_of  :ATTR;
my %enc_alg_of :ATTR;
my %hash_alg_of  :ATTR;

sub START {
    my ($self, $ident, $arg_ref) = @_;

    $engine_of {$ident} = $arg_ref->{ENGINE};
    $pkcs7_of  {$ident} = $arg_ref->{PKCS7};
    $cert_of   {$ident} = $arg_ref->{CERTIFICATE};
    $enc_alg_of{$ident} = $arg_ref->{ENCRYPTION_ALG};
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
    open(my $fh, '<', $certfile) or die "cannot open file $certfile";
    {
        local $/;
        $cert = <$fh>;
    }
    close($fh);

    my $key;
    open(my $fh, '<', $keyfile) or die "cannot open file $keyfile";
    {
        local $/;
        $key = <$fh>;
    }
    close($fh);

    my $encalg = $enc_alg_of{$ident};
    if($encalg == '3DES') {
        $encalg = 'des3';
    }
    my $sigalg = $hash_alg_of{$ident};
    my $pwd    = $engine_of{$ident}->get_passwd();
    my $transid = Crypt::LibSCEP::get_transaction_id($pkcs7_of{$ident});
    my $senderNonce = Crypt::LibSCEP::get_senderNonce($pkcs7_of{$ident});
    my $signerCert = Crypt::LibSCEP::get_signer_cert($pkcs7_of{$ident});
    my $issuedCert = $cert_of{$ident};
    my $pending_reply = Crypt::LibSCEP::create_certificate_reply_wop7({passin=>"pass", passwd=>$pwd, sigalg=>$sigalg, encalg=>$encalg}, $key, $cert, $transid, $senderNonce, $signerCert, $issuedCert, $cert);
    $pending_reply =~ s/\n?\z/\n/;
    $pending_reply =~ s/^(?:.*\n){1,1}//;
    $pending_reply =~ s/(?:.*\n){1,1}\z//;
    use MIME::Base64;
    return decode_base64($pending_reply);
}


1;
__END__