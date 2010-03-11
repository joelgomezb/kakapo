#!/usr/bin/perl -w 

use strict;
use warnings;
use Gtk2 -init;
use Gtk2::GladeXML;
use library;
use Speech::Synthesis;


my ( $programa, $ventana_principal, $vista_text, $file, $buffer_file, $texto, $voz );

	$programa 		= 	Gtk2::GladeXML->new('main.glade');
	$ventana_principal 	= 	$programa->get_widget('ventana_principal');
	$file 			= 	$programa->get_widget('filechooserbutton1');
	$vista_text 		= 	$programa->get_widget('textview1');
	$voz	 		= 	$programa->get_widget('combobox1');
	$programa->signal_autoconnect_from_package('main');

Gtk2->main;

sub on_bcerrar_clicked {
	rutinas::adios("Adios mi amigo");
        Gtk2->main_quit;
}

sub on_hablar_clicked {
	rutinas::tts($texto);
}

sub on_filechooserbutton1_file_set {
	$buffer_file = Gtk2::TextBuffer->new;
	my $archivo_seleccionado = $file->get_filename;
	open(LISTA, $archivo_seleccionado) || die(rutinas::tts("No se pudo abrir el archivo"));
	while(<LISTA>){
		$buffer_file->insert_at_cursor($_);
		$texto .= $_;
	}
	close(LISTA);	
	$vista_text->set_buffer($buffer_file);
}
