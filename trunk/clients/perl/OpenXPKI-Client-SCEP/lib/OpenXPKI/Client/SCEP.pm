# OpenXPKI::Client::SCEP
# Written 2006 by Alexander Klink for the OpenXPKI project
# (C) Copyright 2006 by The OpenXPKI Project
# $Revision: 244 $

package OpenXPKI::Client::SCEP;

use base qw( OpenXPKI::Client );
use OpenXPKI::Server::Context qw( CTX );

use Data::Dumper;

use version; 
($OpenXPKI::Client::SCEP::VERSION = '$Revision: 342 $' )=~ s{ \$ Revision: \s* (\d+) \s* \$ \z }{0.9.$1}xms;
$VERSION = qv($VERSION);

{
    use warnings;
    use strict;
    use Carp;
    use English;

    use Class::Std;

    use OpenXPKI::i18n qw( i18nGettext );
    use OpenXPKI::Debug 'OpenXPKI::Client::SCEP';
    use OpenXPKI::Exception;

    my %operation_of :ATTR( :init_arg<OPERATION> ); # SCEP operation
    my %message_of   :ATTR( :init_arg<MESSAGE>   ); # SCEP message
    my %realm_of     :ATTR( :init_arg<REALM>     ); # PKI realm to use
    my %profile_of   :ATTR( :init_arg<PROFILE>   ); # endentity profile to use
    my %server_of    :ATTR( :init_arg<SERVER>    ); # server to use
    my %enc_alg_of   :ATTR( :init_arg<ENCRYPTION_ALGORITHM> ); 

    my %allowed_op = map { $_ => 1 } qw(
        GetCACaps
        GetCACert
        GetNextCACert
        GetCACertChain

        PKIOperation
    );

    sub START {
        my ($self, $ident, $arg_ref) = @_;
        
        # send configured realm, collect response
        ##! 4: "before talk"
        $self->talk('SELECT_PKI_REALM ' . $realm_of{$ident});
        my $message = $self->collect();
        if ($message eq 'NOTFOUND') {
            die("The configured realm (" . $realm_of{$ident} . ") was not found"
                . " on the server");
        }
        $self->talk('SELECT_PROFILE ' . $profile_of{$ident});
        $message = $self->collect();
        if ($message eq 'NOTFOUND') {
            die("The configured profile (" . $profile_of{$ident} . ") was not found on the server");
        }
        $self->talk('SELECT_SERVER ' . $server_of{$ident});
        $message = $self->collect();
        if ($message eq 'NOTFOUND') {
            die('The configured server (' . $server_of{$ident} . ') was not found on the server');
        }
        $self->talk('SELECT_ENCRYPTION_ALGORITHM ' . $enc_alg_of{$ident});
        $message = $self->collect();
        if ($message eq 'NOTFOUND') {
            die('The configured encryption algorithm (' . $enc_alg_of{$ident} 
                . ') was not found on the server');
        }
    }

    sub send_request {
        my $self = shift;
        my $ident = ident $self;
        my $op = $operation_of{$ident};
        my $message = $message_of{$ident};

        if ($allowed_op{$op}) {
            # send command message to server
            $self->send_command_msg(
                $op,
                {
                  MESSAGE => $message,
                }
            );
        }
        else { # OP is invalid, throw corresponding exception
            OpenXPKI::Exception->throw(
                message => "I18N_OPENXPKI_CLIENT_SCEP_INVALID_OP",
            );
        }
        # get resulting command message from server
        my $server_result = $self->collect();
        return $server_result->{PARAMS};
    }
}
1; # Magic true value required at end of module
__END__

=head1 NAME

OpenXPKI::Client::SCEP - OpenXPKI Simple Certificate Enrollment Protocol Client


=head1 VERSION

This document describes OpenXPKI::Client::SCEP version $VERSION


=head1 SYNOPSIS

    use OpenXPKI::Client::SCEP;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=head2 START

Constructor, see Class::Std.

Expects the following named parameters:

=over

=item REALM

PKI Realm to access (must match server configuration).

=item OPERATION

SCEP operation to send. For allowed operations, see the %allowed_op
hash.

=item MESSAGE

SCEP message to send.

=back

=head2 send_request

Sends SCEP request to OpenXPKI server.

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
OpenXPKI::Client::SCEP requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-openxpki-client-scep@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Martin Bartosch  C<< <m.bartosch@cynops.de> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2006, Martin Bartosch C<< <m.bartosch@cynops.de> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
