package TTS;

use strict;
use warnings;
use Speech::Synthesis;
use File::Slurp;
use Encode;
use File::Temp qw/ tempfile/;
use Exporter;
use Switch;
use Data::Dumper;
use File qw( load_file );
use Glib qw/TRUE FALSE/;

our @ISA    = qw(Exporter);
our @EXPORT = qw( convert );

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

sub convert {
    my ( $self, $file, $sel_filter ) = @_;

	my $syn_default;
    $self->{apply}->set_sensitive(0);
    $self->{applyitem}->set_sensitive(0);
    $self->{play}->set_sensitive(0);
    $self->{playitem}->set_sensitive(0);

    load_file( $self, $file ) unless ( -e $self->{tmp} );
    my $voice = "voice_" . $self->{voices}->get_active_text if ( $self->{syn_default} eq 'Festival' ) ;

	if ( $self->{syn_default} eq 'Festival' ){
		$syn_default = 'Festival';
	}elsif ( $self->{syn_default} eq 'Espeak' ) {
		$syn_default = 'Espeak';
	}else{
		error_msg("Error in config file, no synthesizer detected");
		return 0;
	}
    switch ($sel_filter) {
        case "Archivos Ogg" { toaudio( $self, $file, $sel_filter, $voice, $syn_default ); }
        case "Archivos Mp3" { toaudio( $self, $file, $sel_filter, $voice, $syn_default ); }
    }
}

sub toaudio {
	my ( $self, $file, $sel_fiter, $voice, $syn_default ) = @_;


    my $dialog2 = Gtk2::MessageDialog->new( $self->{window}, [], 'info', 'GTK_BUTTONS_NONE',
        sprintf "Wait a minute, this take a while\n" );

    my $progress = Gtk2::ProgressBar->new;
    $progress->set_pulse_step(.1);
    $dialog2->vbox->pack_start( $progress, FALSE, FALSE, 0 );
    $dialog2->show_all;

	my $running = TRUE;
  	my $timer = Glib::Timeout->add (100, sub { if ($running) {
                                              $progress->pulse;
#												return FALSE if ( $dialog2->run eq 'cancel' );
                                              return TRUE;
                                             }
                                             else {
                                              return FALSE;
                                             } });

    if ( $syn_default eq 'Festival' ){

		open FH, "text2wave $self->{tmp} -o $self->{wav} -eval '($voice)' 1>> $self->{logfile}  2>&1 |" or error_msg( $! );
		$progress->set_text("Creating Wav File");
		open FH2, "lame $self->{wav} -o $file  1>> $self->{logfile}  2>&1 |" or error_msg( $! );
		$progress->set_text("Creating OGG/MP3 File");

	    Glib::IO->add_watch(fileno FH, [ 'in', 'hup' ], sub {
    	        my ( $fileon, $condition ) = @_;

        	    if ( $condition eq 'hup' ) {
					$dialog2->destroy;
					my $dialog = Gtk2::MessageDialog->new( $self->{window}, 'destroy-with-parent', 'info', 'ok',
				        "Finished" );
				    my $resp = $dialog->run;
				    $dialog->destroy if ( $resp eq "ok" );
				    $self->{apply}->set_sensitive(1);
			    	$self->{applyitem}->set_sensitive(1);
				    $self->{play}->set_sensitive(1);
				    $self->{playitem}->set_sensitive(1);

        	        close FH;
            	    close FH2;
                	return FALSE;
            	}

	            return TRUE;

        	}
    	);

	}elsif( $syn_default eq 'Espeak' ){
		open FH, "espeak -f $self->{tmp} -w $self->{wav}  1>> $self->{logfile}  2>&1 |" or error_msg( $! );
		$progress->set_text("Creating Wav File");
		open FH2, "lame $self->{wav} -o $file  1>> $self->{logfile}  2>&1 |" or error_msg( $! );
		$progress->set_text("Creating OGG/MP3 File");

		Glib::IO->add_watch(fileno FH, [ 'in', 'hup' ], sub {
    	        my ( $fileon, $condition ) = @_;

        	    if ( $condition eq 'hup' ) {
					$dialog2->destroy;
					my $dialog = Gtk2::MessageDialog->new( $self->{window}, 'destroy-with-parent', 'info', 'ok',
				        "Finished" );
				    my $resp = $dialog->run;
				    $dialog->destroy if ( $resp eq "ok" );
				    $self->{apply}->set_sensitive(1);
			    	$self->{applyitem}->set_sensitive(1);
				    $self->{play}->set_sensitive(1);
				    $self->{playitem}->set_sensitive(1);

        	        close FH;
            	    close FH2;
                	return FALSE;
            	}

	            return TRUE;

        	});

	}
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

1;    # End of Kakapo
