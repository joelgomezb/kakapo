package Common;

use strict;
use warnings;

use Locale::gettext;
use Encode;
use Exporter;
use POSIX;
use IO::Socket;
use Config::General;

setlocale( LC_MESSAGES, "" );

our @ISA    = qw(Exporter);
our @EXPORT = qw( error_msg question_msg connect_festival );

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

=head2 error_msg
	rutina para mostrar todos los mensajes errores
=cut

sub error_msg {
    my $self = shift;
    my $msg  = shift;

    my $dialog = Gtk2::MessageDialog->new( $self->{window}, 'destroy-with-parent', 'error', 'ok',
        gettext($msg) );

    $dialog->run;
    $dialog->destroy;
}

sub question_msg {
	my $self = shift;
	my $msg = shift;

	my $dialog
        = Gtk2::MessageDialog->new( $self->{window}, 'destroy-with-parent', 'question', 'yes-no', gettext( $msg ) );
    my $resp = $dialog->run;
	$dialog->destroy;
	return $resp;

}

=head2 connect_festival
	rutina para ejecutar el proceso del servidor de festival
=cut

sub connect_festival {
    my $self   = shift;
    my $handle = '';
    my $tries  = 0;

    while ( $handle eq '' ) {
        $self->{log}->debug ("($tries) Attempting to connect to the Festival server.");

        if ($handle = IO::Socket::INET->new(
                Proto    => 'tcp',
                PeerAddr => $self->{host},
                PeerPort => $self->{port}
            )
            )
        {
            $self->{log}->debug("Successfully opened connection to Festival.");
        }
        else {
            if ($tries) {
                $self->{log}->debug(
                    "Waiting for Festival server to load -- Can't connect to port $self->{port} on $self->{host} yet ($!).");
            }
            else {
                if ( $self->{host} eq "localhost" ) {
                    $self->{log}->debug("Failed to connect to Festival server, attempting to load it myself.");
                    system( $self->{cmd} );
                }
            }
            sleep 1;
        }
        $tries++;
    }
    $handle->autoflush(1);
    return $handle;

}

# tengo que hacer el decode los mensajes

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
