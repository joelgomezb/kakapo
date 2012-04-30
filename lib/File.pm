package File;

use strict;
use warnings;
use Speech::Synthesis;
use File::Slurp;
use File::Slurp qw( :edit );
use Encode;
use IO::File;
use Exporter;
use Switch;
use Data::Dumper;
use Glib qw{ TRUE FALSE };
use Gtk2 '-init';
use OpenOffice::OODoc;
use Text::Extract::Word qw(get_all_text);

our @ISA    = qw(Exporter);
our @EXPORT = qw(load_file);

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

sub load_file {
    my ( $self, $file ) = @_;

    my $fh = IO::File->new( $self->{tmp}, "w" );

    my $mime_type = `file --mime-type "$file" | cut -d: -f2 | awk '{print \$1}'`;
    chomp($mime_type);
    $self->{logdebug}->debug($mime_type);

    switch ($mime_type) {
        case "text/plain" { txt( $self, $file ); }
        case "application/pdf" { pdf( $self, $file ); }
        case "application/vnd.oasis.opendocument.text" { odt( $self, $file ); }
        case { "application/msword" || "application/vnd.ms-office" }
        {
            doc( $self, $file );
        }
        else {
            $self->error_msg("File not supported");
            return 1;
        }
    }
}

sub txt {
    my ( $self, $file ) = @_;

    my $buffer_file = Gtk2::TextBuffer->new;
    open( LISTA, $file ) || die error_msg($?);
    while (<LISTA>) {
        $buffer_file->insert_at_cursor( decode( "utf8", $_ ) );
        write_file( $self->{tmp}, { binmode => ':utf8', append => 1 }, decode( "utf8", $_ ) );
    }
    close(LISTA);

    Glib::Timeout->add(
        1000,
        sub {
            $self->{message_id} = $self->{statusbar}->push( $self->{context_id}, $file );
            open ARCHIVO, "<$self->{tmp}" || die error_msg($?);
            my @archivo = <ARCHIVO>;
            $buffer_file->set_text( decode( "utf8", "@archivo" ) );
            $self->{text}->set_buffer($buffer_file);
            my $end_mark = $buffer_file->create_mark( 'end', $buffer_file->get_end_iter, FALSE );
            $self->{text}->scroll_to_mark( $end_mark, 0.0, TRUE, 0.0, 1.0 );
        }
    );
    close(ARCHIVO);

    $self->{apply}->set_sensitive(1);
    $self->{play}->set_sensitive(1);

    $self->{message_id} = $self->{statusbar}->push( $self->{context_id}, "Cargando..." );

}

sub pdf {
    my ( $self, $file ) = @_;

    my $buffer_file = Gtk2::TextBuffer->new;

    Glib::Timeout->add(
        1000,
        sub {
            $self->{message_id} = $self->{statusbar}->push( $self->{context_id}, $file );
            `pdftotext -layout -eol unix '$file' $self->{tmp}`;
            edit_file {s///gi} $self->{tmp};
            open ARCHIVO, "<$self->{tmp}" || die error_msg($?);
            my @archivo = <ARCHIVO>;
            $buffer_file->set_text( decode( "utf8", "@archivo" ) );
            $self->{text}->set_buffer($buffer_file);
            my $end_mark = $buffer_file->create_mark( 'end', $buffer_file->get_end_iter, FALSE );
            $self->{text}->scroll_to_mark( $end_mark, 0.0, TRUE, 0.0, 1.0 );
        }
    );
    close(ARCHIVO);

    $self->{apply}->set_sensitive(1);
    $self->{play}->set_sensitive(1);

    $self->{message_id} = $self->{statusbar}->push( $self->{context_id}, "Cargando..." );
}

sub odt {
    my ( $self, $file ) = @_;

    my $buffer_file = Gtk2::TextBuffer->new;

    `odt2txt '$file' --output=$self->{tmp}`;

    Glib::Timeout->add(
        1000,
        sub {
            $self->{message_id} = $self->{statusbar}->push( $self->{context_id}, $file );
            open ARCHIVO, "<$self->{tmp}" || die error_msg($?);
            my @archivo = <ARCHIVO>;
            $buffer_file->set_text( decode( "utf8", "@archivo" ) );
            $self->{text}->set_buffer($buffer_file);
            my $end_mark = $buffer_file->create_mark( 'end', $buffer_file->get_end_iter, FALSE );
            $self->{text}->scroll_to_mark( $end_mark, 0.0, TRUE, 0.0, 1.0 );
        }
    );
    close(ARCHIVO);

    $self->{apply}->set_sensitive(1);
    $self->{play}->set_sensitive(1);

    $self->{message_id} = $self->{statusbar}->push( $self->{context_id}, "Cargando..." );
}

sub doc {
    my ( $self, $file ) = @_;

    my $buffer_file = Gtk2::TextBuffer->new;

    my $text = get_all_text($file);
    write_file( $self->{tmp}, { binmode => ':utf8', append => 1 }, decode( "utf8", $text ) );

    Glib::Timeout->add(
        1000,
        sub {

            open ARCHIVO, "<$self->{tmp}" || die error_msg($?);
            my @archivo = <ARCHIVO>;
            $buffer_file->set_text( decode( "utf8", "@archivo" ) );
            $self->{text}->set_buffer($buffer_file);
            my $end_mark = $buffer_file->create_mark( 'end', $buffer_file->get_end_iter, FALSE );
            $self->{text}->scroll_to_mark( $end_mark, 0.0, TRUE, 0.0, 1.0 );
        }
    );
    close(ARCHIVO);

    $self->{apply}->set_sensitive(1);
    $self->{play}->set_sensitive(1);
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
