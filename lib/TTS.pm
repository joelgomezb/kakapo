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

    $self->{apply}->set_sensitive(0);
    $self->{play}->set_sensitive(0);

    load_file( $self, $file ) unless ( -e $self->{tmp} );
    my $voice = "voice_" . $self->{voices}->get_active_text;

    #    my $cmd   = "text2wave $self->{tmp} -o $self->{wav} -eval '($voice)'";
    #    system($cmd);

#    switch ($sel_filter) {
#        case "Archivos Ogg" { system("lame $self->{wav} -o $file  1>> $self->{logfile}  2>&1 "); }
#        case "Archivos Mp3" { system("lame $self->{wav} -o $file  1>> $self->{logfile}  2>&1 "); }
#    }
    my $dialog2 = Gtk2::MessageDialog->new( $self->{window}, [], 'info', 'ok',
        sprintf "Wait a minute, this take a while\n" );

    my $progress = Gtk2::ProgressBar->new;
    $progress->set_pulse_step(.1);
    $dialog2->vbox->pack_start( $progress, FALSE, FALSE, 0 );
    $dialog2->show_all;

	 my $running = TRUE;

# Timer will run until callback returns false
  	my $timer = Glib::Timeout->add (100, sub { if ($running) {
                                              $progress->pulse;
                                              return TRUE;
                                             }
                                             else {
                                              return FALSE;
                                             } });

    open FH, "text2wave $self->{tmp} -o $self->{wav} -eval '($voice)' 1>> $self->{logfile}  2>&1 |" or die error_msg( $! );

    Glib::IO->add_watch(fileno FH, [ 'in', 'hup' ], sub {
            my ( $fileon, $condition ) = @_;

            if ( $condition eq 'in' ) {
				 $progress->pulse;
				 print "JoelgomezB\n";
            }

            if ( $condition eq 'hup' ) {
				$dialog2->destroy;
				my $dialog = Gtk2::MessageDialog->new( $self->{window}, 'destroy-with-parent', 'info', 'ok',
			        "Conversion Finalizada" );
			    my $resp = $dialog->run;
			    $dialog->destroy if ( $resp eq "ok" );
			    $self->{apply}->set_sensitive(1);
			    $self->{play}->set_sensitive(1);

                close FH;
                return FALSE;
            }

            return TRUE;

        }
    );

#    system("lame $self->{wav} -o $file  1>> $self->{logfile}  2>&1 ");
}

sub update {
    my $progress = shift;
    $progress->pulse;

    #    while ( Gtk2->events_pending() ) { Gtk2->main_iteration(); }
    return 1;
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
