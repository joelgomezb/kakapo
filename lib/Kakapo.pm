package Kakapo;

use strict;
use warnings;
use Gtk2 '-init';
use Gtk2::Ex::Simple::List;
use Gtk2::GladeXML;
use Speech::Synthesis;
use Config::General;
use File::Slurp;
use base qw( Gtk2::GladeXML::Simple );
use Encode;
use TTS;
use File qw(load_file);
use Data::Dumper;
use Common qw( error_msg );

=head1 NAME

Kakapo - The great new Kakapo!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Kakapo;

    my $foo = Kakapo->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub new {
  my $class = shift;
  my $self = $class->SUPER::new( File::Spec->rel2abs(File::Spec->curdir()) . '/resources/main.glade' );
  return $self;
}

sub run {
  my ( $self ) = @_;

  $self->begin;
  $self->{window}->show;
  $self->{window}->signal_connect('delete_event' => sub { unlink( $self->{tmp} ) if ( -e $self->{tmp} ); Gtk2->main_quit; });
	
  Gtk2->main;
}

sub begin {
	my ( $self ) = @_;

	my $conf = new Config::General( File::Spec->rel2abs(File::Spec->curdir()) . "/kakapo.conf");
	my %config = $conf->getall;

	$self->{tmp} = $config{general}->{tmp};
	$self->{context_id} = $self->{statusbar}->get_context_id("Statusbar");

	$self->{apply}->set_sensitive(0);
	$self->{play}->set_sensitive(0);
	$self->{save}->set_sensitive(0);

	my @installed = `dpkg -l festival | grep i | awk \'{print \$2}'`;
	unless (map (/Festival/i, @installed)) {

		my $dialog =  $self->error_msg("El Paquete 'Festival' no esta instalado en el sistema");
		exit 0;
	}

# tengo que verificar que el proceso de festival  esté corriendo
	my @process = `ps -eaf | grep "festival --server" | awk \'{print \$2}\'`;
	system " (festival --server)  &" if ( @process <= 1 );

	my $engine = 'Festival';
	my @voices = Speech::Synthesis->InstalledVoices(engine => $engine);

	unless ( $voices[0]->{name} ) {
	   	my $dialog = $self->error_msg("No tiene ninguna Voz de Festival instalada");
		exit 0;
	}

	$self->{voices}->new_text;
	foreach (@voices) {
		$self->{voices}->append_text($_->{name});
	}

	$self->{voices}->set_active(0);

}

sub on_hablar_clicked {
	my ( $self ) = @_;
	
		my $buffer_file = Gtk2::TextBuffer->new;
		my $file = $self->{filechooserbutton1}->get_filename;
		convert( $self, $file );
}


sub on_open_clicked {
	my $self = shift;

	my $dialog = Gtk2::FileChooserDialog->new ( 'Abrir archivo', 
											  $self->{window},
 		                                      'open', 
								 			  'gtk-ok' => 'ok',
											  'gtk-cancel' => 'cancel');

	my $filter = Gtk2::FileFilter->new;
	$filter->set_name("Archivos de Texto");
    $filter->add_mime_type("text/*");
	
	my $filter2 = Gtk2::FileFilter->new;
	$filter2->set_name("Archivos pdf");
    $filter2->add_mime_type("application/pdf");

	my $filter3 = Gtk2::FileFilter->new;
	$filter3->set_name("Archivos odt");
    $filter3->add_mime_type("application/vnd.oasis.opendocument.text");

	my $filter4 = Gtk2::FileFilter->new;
	$filter4->set_name("Archivos doc");
    $filter4->add_mime_type("application/msword");
    $filter4->add_mime_type("application/vnd.ms-office");

	my $filter5 = Gtk2::FileFilter->new;
	$filter5->set_name("Archivos docx");
    $filter5->add_mime_type("application/vnd.ms-office");

	$dialog->add_filter($filter);
	$dialog->add_filter($filter2);
	$dialog->add_filter($filter3);
	$dialog->add_filter($filter4);
	$dialog->add_filter($filter5);

	if( $dialog->run eq 'ok' ) {
		my $file = $dialog->get_filename;
		load_file( $self, $file );
		print Dumper($self->{context_id});
    	print "Agarre $file \n";
	 }

	$dialog->destroy;
}

sub on_save_clicked {
	my $self = shift;

	my $dialog = Gtk2::FileChooserDialog->new ( 'Guardar archivo', 
											  $self->{window},
 		                                      'save', 
								 			  'gtk-ok' => 'ok',
											  'gtk-cancel' => 'cancel');

	my $filter = Gtk2::FileFilter->new;
	$filter->set_name("Archivos Ogg");
    $filter->add_mime_type("audio/ogg");

	my $filter2 = Gtk2::FileFilter->new;
	$filter2->set_name("Archivos Mp3");
    $filter2->add_mime_type("audio/mp3");

	$dialog->add_filter($filter);
	$dialog->add_filter($filter2);

	if( $dialog->run eq 'ok' ) {
		my $file = $dialog->get_filename;
		#convert( $self, $file );
		print Dumper($self->{context_id});
	 }

	$dialog->destroy;

	
}

sub on_new_clicked {
	my $self = shift;

	my $buffer_file = Gtk2::TextBuffer->new;
	$buffer_file->set_text("");
	$self->{text}->set_buffer($buffer_file);

	$self->{apply}->set_sensitive(0);
	$self->{play}->set_sensitive(0);
	$self->{save}->set_sensitive(0);
	$self->{statusbar}->push($self->{context_id}, "");
	unlink( $self->{tmp} ) if ( -e $self->{tmp} );
}

sub gtk_main_quit {
	my ( $self ) = shift;
	
	unlink( $self->{tmp} ) if ( -e $self->{tmp} );
	Gtk2->main_quit;
}

sub on_quit_activate {
	my $self = shift;
 
	my $dialog = Gtk2::MessageDialog->new($self->{window},
    	                                  'destroy-with-parent',
        	                              'question',
            	                          'yes-no',
                	                      "Esta Seguro que desea Salir?");
	my $resp = $dialog->run;
	$self->gtk_main_quit if ( $resp eq "yes" );
	$dialog->destroy;
;
}

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Joel Gomez, C<< <joelgomezb at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-kakapo at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Kakapo>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Kakapo


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Kakapo>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Kakapo>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Kakapo>

=item * Search CPAN

L<http://search.cpan.org/dist/Kakapo/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Joel Gomez.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2 dated June, 1991 or at your option
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

A copy of the GNU General Public License is available in the source tree;
if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


=cut

1; # End of Kakapo
