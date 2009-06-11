package Demeter::Mode;

use MooseX::Singleton;
use MooseX::AttributeHelpers;
#use Demeter::Config;
use Demeter::StrTypes qw( Empty
			  TemplateProcess
			  TemplateFit
			  TemplatePlot
			  TemplateFeff
			  TemplateAnalysis
		       );
use Regexp::List;
use Regexp::Optimizer;
my $opt = Regexp::List->new;

use vars qw($singleton);	# Moose 0.61, MooseX::Singleton 0.12 seem to need this

## -------- disposal modes
has 'ifeffit' => (is => 'rw', isa => 'Bool',         default => 1);
has $_        => (is => 'rw', isa => 'Bool',         default => 0)   foreach (qw(screen plotscreen repscreen));
has $_        => (is => 'rw', isa => 'Str',          default => q{}) foreach (qw(file plotfile repfile));
has 'buffer'     => (is => 'rw', isa => 'ArrayRef | ScalarRef');
has 'plotbuffer' => (is => 'rw', isa => 'ArrayRef | ScalarRef');

has 'callback'     => (is => 'rw', isa => 'CodeRef');
has 'plotcallback' => (is => 'rw', isa => 'CodeRef');
has 'feedback'     => (is => 'rw', isa => 'CodeRef');

## -------- default objects for templates
has 'config'   => (is => 'rw', isa => 'Any');  #         Demeter::Config);
has 'plot'     => (is => 'rw', isa => 'Any');  #         Demeter::Plot);
has 'fit'      => (is => 'rw', isa => 'Any');  # Empty.'|Demeter::Fit');
has 'standard' => (is => 'rw', isa => 'Any');  # Empty.'|Demeter::Data');
has 'theory'   => (is => 'rw', isa => 'Any');  # Empty.'|Demeter::Feff');
has 'path'     => (is => 'rw', isa => 'Any');  # Empty.'|Demeter::Path');

## -------- templates sets
has 'template_process'  => (is => 'rw', isa => 'Str', default => 'ifeffit');
has 'template_fit'      => (is => 'rw', isa => 'Str', default => 'ifeffit');
has 'template_analysis' => (is => 'rw', isa => 'Str', default => 'ifeffit');
has 'template_plot'     => (is => 'rw', isa => 'Str', default => 'pgplot');
has 'template_feff'     => (is => 'rw', isa => 'Str', default => 'feff6');
# has 'template_process'  => (is => 'rw', isa => 'TemplateProcess',  default => 'ifeffit');
# has 'template_fit'      => (is => 'rw', isa => 'TemplateFit',      default => 'ifeffit');
# has 'template_analysis' => (is => 'rw', isa => 'TemplateAnalysis', default => 'ifeffit');
# has 'template_plot'     => (is => 'rw', isa => 'TemplatePlot',     default => 'pgplot');
# has 'template_feff'     => (is => 'rw', isa => 'TemplateFeff',     default => 'feff6');
# has 'template_test'     => (is => 'ro', isa => 'Str',              default => 'test');

## -------- class collector arrays for sentinel functionality
has 'Atoms' => (
		metaclass => 'Collection::Array',
		is        => 'rw',
		isa       => 'ArrayRef',
		default   => sub { [] },
		provides  => {
			      'push'    => 'push_Atoms',
			      'clear'   => 'clear_Atoms',
			      'splice'  => 'splice_Atoms',
			     }
	       );
has 'Data' => (
		metaclass => 'Collection::Array',
		is        => 'rw',
		isa       => 'ArrayRef',
		default   => sub { [] },
		provides  => {
			      'push'    => 'push_Data',
			      'clear'   => 'clear_Data',
			      'splice'  => 'splice_Data',
			     }
	       );
has 'Feff' => (
		metaclass => 'Collection::Array',
		is        => 'rw',
		isa       => 'ArrayRef',
		default   => sub { [] },
		provides  => {
			      'push'    => 'push_Feff',
			      'clear'   => 'clear_Feff',
			      'splice'  => 'splice_Feff',
			     }
	       );
has 'Fit' => (
		metaclass => 'Collection::Array',
		is        => 'rw',
		isa       => 'ArrayRef',
		default   => sub { [] },
		provides  => {
			      'push'    => 'push_Fit',
			      'clear'   => 'clear_Fit',
			      'splice'  => 'splice_Fit',
			     }
	       );
has 'GDS' => (
		metaclass => 'Collection::Array',
		is        => 'rw',
		isa       => 'ArrayRef',
		default   => sub { [] },
		provides  => {
			      'push'    => 'push_GDS',
			      'clear'   => 'clear_GDS',
			      'splice'  => 'splice_GDS',
			     }
	       );
has 'Path' => (
		metaclass => 'Collection::Array',
		is        => 'rw',
		isa       => 'ArrayRef',
		default   => sub { [] },
		provides  => {
			      'push'    => 'push_Path',
			      'clear'   => 'clear_Path',
			      'splice'  => 'splice_Path',
			     }
	       );
has 'Plot' => (
		metaclass => 'Collection::Array',
		is        => 'rw',
		isa       => 'ArrayRef',
		default   => sub { [] },
		provides  => {
			      'push'    => 'push_Plot',
			      'clear'   => 'clear_Plot',
			      'splice'  => 'splice_Plot',
			     }
	       );
has 'ScatteringPath' => (
		metaclass => 'Collection::Array',
		is        => 'rw',
		isa       => 'ArrayRef',
		default   => sub { [] },
		provides  => {
			      'push'    => 'push_ScatteringPath',
			      'clear'   => 'clear_ScatteringPath',
			      'splice'  => 'splice_ScatteringPath',
			     }
	       );
has 'VPath' => (
		metaclass => 'Collection::Array',
		is        => 'rw',
		isa       => 'ArrayRef',
		default   => sub { [] },
		provides  => {
			      'push'    => 'push_VPath',
			      'clear'   => 'clear_VPath',
			      'splice'  => 'splice_VPath',
			     }
	       );
has 'SSPath' => (
		metaclass => 'Collection::Array',
		is        => 'rw',
		isa       => 'ArrayRef',
		default   => sub { [] },
		provides  => {
			      'push'    => 'push_SSPath',
			      'clear'   => 'clear_SSPath',
			      'splice'  => 'splice_SSPath',
			     }
	       );
has 'Prj' => (
		metaclass => 'Collection::Array',
		is        => 'rw',
		isa       => 'ArrayRef',
		default   => sub { [] },
		provides  => {
			      'push'    => 'push_Prj',
			      'clear'   => 'clear_Prj',
			      'splice'  => 'splice_Prj',
			     }
	       );


## -------- The Professor and Mary Anne
has 'iwd' => (is => 'rw', isa => 'Str', default => q{});
has 'cwd' => (is => 'rw', isa => 'Str', default => q{});

has 'pathindex' => (is => 'rw', isa => 'Int', default => 1);

has 'echo'		   => (is => 'rw', isa => 'Any');
has 'datadefault'	   => (is => 'rw', isa => 'Any');
has 'external_plot_object' => (is => 'rw', isa => 'Any');
has 'plotting_initialized' => (is => 'rw', isa => 'Bool', default => 0);
has 'identity'             => (is => 'rw', isa => 'Str',  default => 'Demeter',);
has 'ui'                   => (is => 'rw', isa => 'Str',  default => 'none',);

sub fetch {
  my ($self, $type, $group) = @_;
  return 0 if ($type !~ m{(?:Atoms|Data|Feff|Fit|GDS|Path|Plot|ScatteringPath|VPath|SSPath|Prj)});
  my $list = $self->$type;
  foreach my $o (@$list) {
    return $o if ($o->group eq $group);
  };
  return 0;
};

sub remove {
  my ($self, $object) = @_;
  my $type = (split(/::/, ref $object))[-1];
  ($type = 'Plot') if ($type eq 'Gnuplot');
  my $group = $object->group;
  my ($i, $which) = (0, -1);
  return if ($#{$self->$type} == -1);
  foreach my $o (@{$self->$type}) {
    if (defined($o) and ($o->group eq $group)) {
      $which = $i;
      last;
    };
    ++$i;
  };
  return if ($which == -1);
  my $method = "splice_".$type;
  #local $| = 1;
  #print join("|", $#{$self->$type}, $method, $type, $which), $/;
  $self->$method($which, 1);
};

sub everything {
  my ($self) = @_;
  return (@{ $self->Atoms	   },
	  @{ $self->Data	   },
	  @{ $self->Feff	   },
	  @{ $self->Fit		   },
	  @{ $self->GDS		   },
	  @{ $self->Path	   },
	  @{ $self->Plot	   },
	  @{ $self->ScatteringPath },
	  @{ $self->VPath	   },
	  @{ $self->SSPath	   },
	  @{ $self->Prj		   });
};

sub destroy_all {
  my ($self) = @_;
  foreach my $obj ($self->everything) {
    #print $obj;
    $obj -> DESTROY;
  };
};


__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

Demeter::Mode - Demeter's sentinel system

=head1 VERSION

This documentation refers to Demeter version 0.3.

=head1 DESCRIPTION

This special object is used to store global attributes of an instance
of Demeter in a way that makes those attributes available to any
Demeter object.

Access to this object is via the C<get_mode> and C<set_mode> methods
of the Demeter base class.  The convenience methods C<co> and C<po> of
the Demeter base class are used to gain access to the Config and Plot
objects.  Any of these methods can be called by any Demeter object:

  $to_screen = $data_object     -> get_mode('screen');
  $to_screen = $gds_object      -> get_mode('screen');
  $to_screen = $path_object     -> get_mode('screen');
  $to_screen = $scattering_path -> get_mode('screen');
  $to_screen = $prj_object      -> get_mode('screen');
    ## and so on ...

This object also monitors the creation and destruction of Demeter
objects (Atoms, Data, Data::Prj, Feff, Fit, GDS, Path, Plot,
Scattering_Path, SSPath, and VPath) and provides methods which give a
way for one object to affect any other objects created during the
instance of Demeter.  For example, when the kweight value of the Plot
object is changed, it is necessary to signal all Data objects that
they will need to update their forward Fourier transforms.  This
object is the glue that allows things like that to happen.

=head1 ATTRIBUTES

=head2 Disposal modes

=over 4

=item C<ifeffit>

Dispose commands to Ifeffit when true.

=item C<screen>

Dispose commands to STDOUT when true.

=item C<plotscreen>

Dispose plotting commands to STDOUT when true.

=item C<repscreen>

Dispose reprocessed commands to STDOUT when true.

=item C<file>

Dispose commands to a file when a filename is given.

=item C<plotfile>

Dispose plotting commands to a file when a filename is given.

=item C<repfile>

Dispose reprocessed commands to a file when a filename is given.

=item C<buffer>

Dispose commands to a string or array when given a reference to a
string or array.

=item C<plotbuffer>

Optionally dispose of plotting commands to a difference string or
array reference.

=item C<callback>

Dispose commands by sending them as the argument to a user-supplied
code rerference.

=item C<plotcallback>

Optionally dispose of plotting commands to a difference code
reference.

=item C<feedback>

A code ref for disposing of feedback from Ifeffit.

=back

=head2 Template objects

=over 4

=item C<config>

A reference to the singleton Config object.  C<$C> is the special
template variable.

=item C<plot>

A reference to the current Plot object.  C<$P> is the special
template variable.

=item C<fit>

A reference to the current Fit object.  C<$F> is the special
template variable.

=item C<standard>

A reference to the current Data object used a data processing
standard.  C<$DS> is the special template variable.

=item C<theory>

A reference to the current Feff object.  C<$T> is the special
template variable.

=item C<path>

A reference to the current Path object.  C<$PT> is the special
template variable.

=back

=head2 Template sets

=over 4

=item C<template_process>

The template set to use for processing data.

=item C<template_fit>

The template set to use for fitting data.

=item C<template_analysis>

The template set to use for analyzing mu(E) data.

=item C<template_plot>

The template set to use for plotting data.

=item C<template_feff>

The template set to use for writing F<feff.inp> files.

=item C<template_test>

A special template set used for testing Demeter.

=back

=head2 Object collections

=over 4

=item C<Atoms>

A list of all Atoms objects created during this instance of Demeter.

=item C<Data>

A list of all Data objects created during this instance of Demeter.

=item C<Feff>

A list of all Feff objects created during this instance of Demeter.

=item C<Fit>

A list of all Fit objects created during this instance of Demeter.

=item C<GDS>

A list of all GDS objects created during this instance of Demeter.

=item C<Path>

A list of all Path objects created during this instance of Demeter.

=item C<Plot>

A list of all Plot objects created during this instance of Demeter.

=item C<ScatteringPath>

A list of all ScatteringPath objects created during this instance of Demeter.

=item C<VPath>

A list of all VPath objects created during this instance of Demeter.

=item C<SSPath>

A list of all SSPath objects created during this instance of Demeter.

=item C<Prj>

A list of all Data::Prj objects created during this instance of Demeter.

=back

=head2 Other attributes

=over 4

=item C<iwd>

The initial working directory when Demeter starts.

=item C<cwd>

Demeter's current working directory.

=item echo

???

=item C<datadefault>

This is a Data object used as a fallback.  For instance, one might
want to process and plot Path objects without having imported a Data
object.  This global attribute will be used in that case to properly
process and plot the Path.

=item C<external_plot_object>

For plotting backends that have an objective interface, this global
attribute carried the refernece to that object.  For example, in the
gnuplot backend, this contains a reference to the
L<Graphics::GnuplotIF> object.

=item C<ui>

This is a string identifying the user interface backend.  At this
time, its only use is to tell the Fit object to import the
curses-based methods in L<Demeter::UI::Screen::Interview> and
L<Demeter::UI::Screen::Spinner> when it is set to C<screen>.  Future
possibilities might include C<wx> or C<rpc>.

=back

=head1 SENTINEL FUNCTIONALITY

It should rarely be necessary that a user script needs to access this
part of this object.  Mostly the sentinel functionality is handled
behind the scenes, during object creation or destruction or at the end
of a script.  The details are documented here for those times when one
needs to see under the hood.

Each Demeter object (Atoms, Data, Data::Prj, Feff, Fit, GDS, Path,
Plot, Scattering_Path, SSPath, and VPath) (Data::Prj is refered to
just as Prj) has each of the following three function associated with
it.

All of my examples use the Data object.

=over 4

=item I<Object>

This is the accessor for the attribute which holds the list of all
Data objects created during this instance of Demeter.

  my @list = @{ $object->mo->Data };

=item C<push_>I<Object>

This is the method used to append an object to the list;

  $data_object->push_Data($data_object);

This happens automatically when a Data object is created.

=item C<clear_>I<Object>

This method is used to clear the contents of the list.

  $data_object->clear_Data;

This is not used for anything at this time, but it seemed useful.

=back

=head2 Sentinel methods

=over 4

=item C<fetch>

This method returns and object reference given its group name.

  $object = $demeter_object->mo->fetch("ScatteringPath", $group);

In this example, the ScatteringPath object whose group name is $group
will be returned.  The first argument is one of the Demeter object
types.  This method was written to facilitate drag and drop in the Wx
version of Artemis.  Wx's drag and drop capability does not easily do
DND on blessed references.  It was much easier to do DND on an array
of group names, which are simple strings.  I then needed this method
to convert the list of group names back into a list of object
references.

=back

=head1 DIAGNOSTICS

Moose type constraints are used on several of the GDS object
attributes.  Error messages appropriate to the type constrain will be
generated.

=head1 SERIALIZATION AND DESERIALIZATION

See the discussion of serialization and deserialization in
C<Demeter::Fit>.

=head1 CONFIGURATION AND ENVIRONMENT

See L<Demeter::Config> for a description of the configuration system.

=head1 DEPENDENCIES

Demeter's dependencies are in the F<Bundle/DemeterBundle.pm> file.

=head1 BUGS AND LIMITATIONS

=over 4

=item *

Errors should be propagated into def parameters

=back

Please report problems to Bruce Ravel (bravel AT bnl DOT gov)

Patches are welcome.

=head1 AUTHOR

Bruce Ravel (bravel AT bnl DOT gov)

L<http://cars9.uchicago.edu/~ravel/software/>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2006-2009 Bruce Ravel (bravel AT bnl DOT gov). All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlgpl>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
