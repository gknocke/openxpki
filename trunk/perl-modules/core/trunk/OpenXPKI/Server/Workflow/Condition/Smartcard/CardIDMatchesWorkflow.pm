# OpenXPKI::Server::Workflow::Condition::Smartcard::CardIDMatchesWorkflow.pm
# Written by Scott Hardin for the OpenXPKI project 2009
#
# Based on OpenXPKI::Server::Workflow::Condition::IsValidSignature.pm
# Written by Alexander Klink for the OpenXPKI project 2006
# Copyright (c) 2009 by The OpenXPKI Project
package OpenXPKI::Server::Workflow::Condition::Smartcard::CardIDMatchesWorkflow;

use strict;
use warnings;
use base qw( Workflow::Condition );
use Workflow::Exception qw( condition_error configuration_error );
use OpenXPKI::Server::Context qw( CTX );
use OpenXPKI::Debug;
use OpenXPKI::DN;

use English;

use Data::Dumper;

sub evaluate {
    ##! 16: 'start'
    my ( $self, $workflow ) = @_;

	condition_error('I18N_OPENXPKI_SERVER_WORKFLOW_CONDITION_NOT_IMPLEMENTED');
    return -1;

}

1;

__END__

=head1 NAME

OpenXPKI::Server::Workflow::Condition::Smartcard::CardIDMatchesWorkflow

=head1 SYNOPSIS

<action name="do_something">
  <condition name="valid_signature_with_requested_dn"
             class="OpenXPKI::Server::Workflow::Condition::Smartcard::CardIDMatchesWorkflow">
  </condition>
</action>

=head1 DESCRIPTION

This is not implemented yet.
