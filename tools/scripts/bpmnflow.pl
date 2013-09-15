#!/usr/bin/perl

### TO DO###
#where to get the namespace? not in bpmn file yet
#all kinds of error checking
#input validation
#git elements
#make file
#validators?
#arguments from console like verbose output, filenames etc?
#finalizing bpmn conventions
#code cleanup
#more comments
#create a pdf with all conventions listed
#split main into seperated functions for better reading
#better regex replaces, currently just questionmarks and spaces will be removed


use strict;
use warnings;
use XML::Simple;

my $indentSpace = ' ' x 4;
my $namespace = '';
my $descPrefix = '';
my $i18nPrefix  = 'I18N_OPENXPKI_WF';
our @objs = ();

#each element will be maped to an object, consisting of all necessary information and a dumping routine. 
package ObjStateAction;
use Moose;
has type => (is => 'ro', default => 'stateaction');
has name => (is => 'rw',);
has resState => (is => 'rw');
has conditions => (is => 'rw', isa => 'ArrayRef');
no Moose;

sub dump {
	my $self = shift;
	my $indent = shift || 0;
	my @conditionnames = ();
	my $actionname = $descPrefix."_".$self->{name};
	my $resState = uc($self->{resState});
	my @out = ();
	if (defined $self->{conditions}) {
		@conditionnames = @{$self->{conditions}};
	}
	$actionname =~ s/\s/_/g;
	$resState =~ s/\s/_/g;
	push @out, $indentSpace x $indent, '<action name="', $actionname , '" ', "resulting_state=", '"', $resState, '"', ">", "\n";
	foreach (@conditionnames) {
		push @out, $indentSpace x ($indent + 1), '<condition name="', $_ , '"', "/>", "\n";
	}
	return @out;
}

package ObjState;
use Moose;
has type => (is => 'ro', default => 'state');
has name => (is => 'rw',);
has id => (is => 'rw',);
has targetRef => (is => 'rw',);
has description => (is => 'rw',);
has action => (is => 'rw', isa => 'ArrayRef');
has counter => (is => 'rw', default => 1);
has autorun => (is => 'rw');
no Moose;

sub dump {
	my $self = shift;
	my $indent = shift || 0;
	my @out = ();
	my $name = $self->name;
	my @conditionnames = ();
	$name =~ s/\s/_/g;
	
	push @out, $indentSpace x $indent++;
    push @out, '<state name="', $name, '"';

	if (defined $self->{autorun}) {
		push @out, "\n", $indentSpace x $indent, 'autorun="yes"';
	}
	push @out, '>', "\n";
    push @out, $indentSpace x $indent, '<description>',
        $i18nPrefix, '_STATE_', uc($descPrefix), '_', $name,
        '</description>', "\n";
	if (defined ($self->{action})) {
		foreach(@{$self->{action}}) {
			push @out, $_->dump($indent);
		}
	}

    $indent--;
    push @out, $indentSpace x $indent;
    push @out, '</state>', "\n";
    return @out;
}

package ObjCondition;
use Moose;
has type => (is => 'ro', default => 'condition');
has name => (is => 'rw',);
has id => (is => 'rw',);
has class => (is => 'rw',);
has plist => (is => 'rw', isa => 'HashRef');
has targetRef => (is => 'rw', isa => 'ArrayRef');
has default => (is => 'rw',);
no Moose;

sub dump {
	my $self = shift;
	my $indent = shift || 0;
	my $class = "Workflow::Action::Null";
	if ( defined ($self->{class}) ) {
		$class = $self->{class};
	}
	
	my $name = $namespace . '_' . $self->{name};
	$name =~ s/\s/_/g;
	$name =~ s/\?//g;
	my @out = ();
	push @out, $indentSpace x $indent++;
	push @out, "<condition name=", '"', "$name", '"', "\n";
	push @out, $indentSpace x ($indent + 1) , "class=", '"', "$class", '"', ">", "\n";
	while( my ($k, $v) = each %{$self->{plist}} ) {
		push @out, $indentSpace x $indent , "<param name=", '"', "$k", '" ', "value=", '"', "$v", '"', " />", "\n";
	}
	$indent--;
	push @out, $indentSpace x $indent, "</condition>", "\n";
	return @out;
}

package ObjAction;
use Moose;
has type => (is => 'ro', default => 'action');
has name => (is => 'rw',);
has id => (is => 'rw',);
has class => (is => 'rw',);
has reqparams => (is => 'rw', isa => 'ArrayRef');
has optparams => (is => 'rw', isa => 'ArrayRef');
has condition => (is => 'rw',);
has targetRef => (is => 'rw',);
no Moose;

sub dump {
	my $self = shift;
	my $indent = shift || 0;
	my $class = "Workflow::Action::Null";
	my @reqparams = ();
	my @optparams = ();
	if ( defined ($self->{class}) ) {
		$class = $self->{class};
	}
	
	if (defined $self->reqparams) {
		@reqparams = @{$self->reqparams};	
	}
	
	if (defined $self->optparams) {
		@optparams = @{$self->optparams};	
	}
	
	my $name = $namespace . '_' . $self->{name};
	$name =~ s/\s/_/g;
	my @out = ();
	push @out, $indentSpace x $indent++;
	push @out, "<action name=", '"', "$name", '"', "\n";
	push @out, $indentSpace x ($indent + 1) , "class=", '"', "$class", '"', ">", "\n";
	foreach my $param(@reqparams) {
		push @out, $indentSpace x ($indent + 1) , "<field name=", '"', "$param", '"', " isRequired=", '"', "yes", '"', "/>", "\n";
	}
	foreach my $param(@optparams) {
		push @out, $indentSpace x ($indent + 1) , "<field name=", '"', "$param", '"', "/>", "\n";
	}
	$indent--;
	push @out, $indentSpace x $indent, "</action>", "\n";
	return @out;
}

package ObjRef;
use Moose;
has type => (is => 'ro', default => 'flow');
has id => (is => 'rw',);
has targetRef => (is => 'rw',);
no Moose;


package Main;
use Data::Dumper;

sub getElementById {
	my $id = shift;
	for (grep {$_->{id} eq $id} @objs) {
		return $_;
	}
	return;
}

sub getNextElements {
	my $currElement = getElementById(shift);
	my @nextRefs = ();
	my @targets = ();
	
	if (ref($currElement->{targetRef}) ne 'ARRAY') {
		push @nextRefs, $currElement->{targetRef};
	}
	else {
		@nextRefs = @{$currElement->{targetRef}};
	}
	
	foreach (@nextRefs) {
		my $tempElement = getElementById($_);
		if ($tempElement->{type} eq 'flow') {
			push @targets, getElementById($tempElement->{targetRef});
		}
		else {
			push @targets, $tempElement;
		}
	}
	return \@targets;
}

sub handleAction {
	my $state = shift;
	my $action = shift;
	my $conditions = shift || [];
	my $object = ObjStateAction->new();
	$object->name($action->{name});
	$object->resState(shift(@{getNextElements($action->{id})})->{name});
	$object->conditions($conditions);
	push(@{$state->{action}}, $object);
}

sub handleState {
	my $state = shift;
	my $resState = shift;
	my $conditions = shift || [];
	my $object = ObjStateAction->new();
	$object->name("null".$state->{counter});
	$state->counter($state->{counter} + 1);
	$object->resState($resState->{name});
	$object->conditions($conditions);
	push(@{$state->{action}}, $object);
	unless (getElementById($object->{name})) {
		my $action = ObjAction->new;
		$action->id($object->{name});
		$action->name($object->{name});
		push @objs, $action;
	}
}

sub handleCondition {
	my $state = shift;
	my $cond = shift;
	my $condname = $descPrefix."_".$cond->{name};
	$condname=~ s/\s/_/g;
	$condname=~	s/\?//g;
	my $conditions = shift || [];
	my @nodes = @{getNextElements($cond->{id})};
	my $default = getElementById($cond->{default})->{targetRef};
	
	foreach(@nodes) {
		my @temp = ();
		if ($_->{id} eq $default) {
			@temp = @{$conditions};	
			push @temp, $condname;
		}
		else {
			@temp = @{$conditions};	
			push @temp, "!".$condname;
		}

		if ($_->{type} eq 'action') {
			handleAction($state, $_, \@temp);
		}
		elsif ($_->{type} eq 'state') {
			handleState($state, $_, \@temp);
		}
		elsif ($_->{type} eq 'condition') {
			handleCondition($state, $_, \@temp);
		}
	}
}


sub createStateChilds {
	my $state = shift;
	if ($state->{type} eq 'state') {
		#states only have one next element: action or condition
		my $element = shift(@{getNextElements($state->{id})});
		if ($element->{type} eq 'action') {
			handleAction($state, $element);
		}
		#if next element is condition
		else {
			handleCondition($state, $element);
		}
	}
}

# this routine filters all important objects and refers them to their corresponding procedure
sub parseContent {
	my $content = shift;
	foreach my $element (keys %{$content} ) {
		if ( $element eq 'sequenceFlow') {
			foreach my $flow ( @{$content->{$element}} ) {
				parseFlow($flow);
			}
		}
		elsif ( $element eq 'task' ) {
			foreach my $task ( @{$content->{$element}} ) {
				parseTask($task);
			}
		}
		elsif (
				$element eq 'endEvent' ||
				$element eq 'startEvent'||
				$element eq 'intermediateThrowEvent' ||
				$element eq 'intermediateCatchEvent' )
		{
			foreach my $event ( @{$content->{$element}} ) {
				parseEvent($event);
			}
		}
		elsif (	$element eq 'exclusiveGateway' ) {
			foreach my $gateway ( @{$content->{$element}} ) {
				parseGateway($gateway);
			}
		}	
	}
	#remove link events
	foreach my $list1 (grep {$_->{linkEventDefinition}} @{$content->{intermediateThrowEvent}} ) {
		my @incomings = ();
		foreach (@{$list1->{incoming}}) {
			push @incomings, getElementById($_);
		}
		foreach my $list2 (@{$content->{intermediateCatchEvent}}) {
			if ($list2->{name} eq $list1->{name}) {
				my $targetid = getElementById($list2->{outgoing}->[0])->{targetRef};
				foreach (@incomings) {
					$_->{targetRef} = getElementById($targetid)->{id};
				}
				for (grep {$objs[$_]->{id} eq $list1->{id}} 0..$#objs) {
					splice @objs, $_, 1;
				}
				for (grep {$objs[$_]->{id} eq $list2->{id}} 0..$#objs) {
					splice @objs, $_, 1;
				}
			}
		}
	}
	
	foreach (grep {$_->{type} eq 'state'} @objs) {
		if ( defined ($_->{targetRef})) {
			createStateChilds($_);
		}
	}
}

sub parseTask {
	my $task = shift;
	my $object = ObjAction->new;
	$object->id($task->{id});
	$object->name($task->{name});
	$object->class($task->{property}->[0]->{name});
	$object->targetRef($task->{outgoing}->[0]);
	
	#this will catch the required and optional parameter. 
	#currently they are seperated by a single space,
	# the keyword (required/optional) has to be the first
	#probably not the most reliable way
	foreach my $param (@{$task->{ioSpecification}->[0]->{dataInput}}) {
		my @names = split(/ /,$param->{name});
		if (shift(@names) eq 'required') {
			$object->reqparams(\@names);
		}
		#maybe not the best idea, error handling missing
		else {
			$object->optparams(\@names);
		}
	}
	push @objs, $object;
}

sub parseFlow {
	my $flow = shift;
	my $object = ObjRef->new;
	$object->id($flow->{id});
	$object->targetRef($flow->{targetRef});
	push @objs, $object;
}

sub parseEvent {
	my $event = shift;
	my $name = $event->{name};
	my $id = $event->{id};	
	my $object = ObjState->new;
	$object->id($id);
	$object->name($name);
	$object->targetRef($event->{outgoing}->[0]);
	if (defined $event->{property}) {
		my $autorun = $event->{property}->[0]->{name};
		$autorun = (split (/ /, $autorun))[1];
		$object->autorun($autorun);
	}

	push @objs, $object;
}

sub parseGateway {
	my $gateway = shift;
	my $name = $gateway->{name};
	my $id = $gateway->{id};	
	my $object = ObjCondition->new;
	$object->id($id);
	$object->name($name);
	$object->plist({});
	$object->targetRef($gateway->{outgoing});
	$object->default($gateway->{default});
	
	foreach my $param (@{$gateway->{documentation}}) {
		my ($param1, $param2) = split / /, $param->{content}, 2;
		if ($param1 eq 'class') {
			$object->class($param2);
		}
		elsif ($param1 eq 'name') {
			my ($name, $value) = split /name |; value /, $param2, 2;
			${$object->plist}{$name} = $value;
		}
	}
	push @objs, $object;
}

#main routine starts

use Getopt::Long;

my ($infile, $outfile, $outtype);


my $result = GetOptions(
    "infile=s"    => \$infile,
    "outfile=s"   => \$outfile,
    "outtype=s"   => \$outtype,
    "namespace=s" => \$namespace,
);

$infile ||= $ARGV[0];

unless ( open FILE, $infile ) {
    die("Could not open $infile");
}

my $data = do { local $/; <FILE> };
close FILE;

my $xml = XML::Simple::XMLin($data, ForceArray => 1, keyattr => {});

if ( defined ($xml->{name}) ) {
	$namespace = $xml->{name};
}

#descPrefix ist currently missing in BPMN file
$descPrefix = $namespace;

#this will parse the important part of the xml file
parseContent($xml->{process}->[0]);

my $imprint
    = '<!-- Generated by "' 
    . $0 . ' '
    . join( ', ', @ARGV ) . '" -->' . "\n\n";
	
# write action definitions to file
if ( not $outtype or $outtype eq 'actions' ) {
	my $defName = $outfile
		|| 'workflow_activity_' . lc($descPrefix) . '.xml';
	open( DEF, ">$defName" ) or die "Error opening $defName: $!";
	my $indent = 0;
	print DEF $imprint, "\n";
	print DEF $indentSpace x $indent, '<actions>', "\n\n";
	$indent++;

	foreach my $rec ( grep{defined($_->{type}) && $_->{type} eq 'action'}  @objs) {
		print DEF $rec->dump($indent), "\n";
		}
		
	$indent--;
	print DEF $indentSpace x $indent, '</actions>', "\n";
	close DEF;
}

# write condition definitions to file
if ( not $outtype or $outtype eq 'conditions' ) {
	my $defName = $outfile
		|| 'workflow_condition_' . lc($descPrefix) . '.xml';
	open( DEF, ">$defName" ) or die "Error opening $defName: $!";
	my $indent = 0;
	print DEF $imprint, "\n";
	print DEF $indentSpace x $indent, '<conditions>', "\n\n";
	$indent++;

	foreach my $rec ( grep{defined($_->{type}) && $_->{type} eq 'condition'}  @objs) {
		print DEF $rec->dump($indent), "\n";
		}
		
	$indent--;
	print DEF $indentSpace x $indent, '</conditions>', "\n";
	close DEF;
}

# write state definitions to file
if ( not $outtype or $outtype eq 'states' ) {
	my $defName = $outfile
		|| 'workflow_def_' . lc($descPrefix) . '.xml';
	open( DEF, ">$defName" ) or die "Error opening $defName: $!";
	my $indent = 0;
	print DEF $imprint, "\n";
	print DEF $indentSpace x $indent, '<workflow>', "\n";
		$indent++;
		print DEF $indentSpace x $indent, '<type>',
			$i18nPrefix, '_TYPE_', uc($descPrefix),
			'</type>', "\n";
		print DEF $indentSpace x $indent, '<description>',
			$i18nPrefix, '_DESC_', uc($descPrefix),
			'</description>', "\n";
		print DEF $indentSpace x $indent,
			'<persister>OpenXPKI</persister>',
			"\n\n";

	#this one greps every unique state
	my %seen;
	my @unique = grep{$_->{type} eq 'state' &&
					! $seen{$_->{name}}++ } @objs;

	foreach my $rec (@unique) {
		print DEF $rec->dump($indent), "\n";
	}
		
	$indent--;
	print DEF $indentSpace x $indent, '</workflow>', "\n";
	close DEF;
}
