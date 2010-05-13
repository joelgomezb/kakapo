#!/usr/bin/perl 
use Speech::Synthesis;

package rutinas;

sub adios {
    	my $engine = 'Festival';
	my @voices = Speech::Synthesis->InstalledVoices( engine => $engine );
	my @avatars = Speech::Synthesis->InstalledAvatars( engine => $engine );
	
        my $ss = Speech::Synthesis->new(
					engine => 'Festival', 
					avatar => undef, 
					language => 'es', 
					voice => 'JuntaDeAndalucia_es_pa_diphone', 
					async => 0, 
				       );
	    $ss->speak( $_[0] || "test" );
}

sub tts {
	my $engine = 'Festival';
	my @voices = Speech::Synthesis->InstalledVoices( engine => $engine );
	my @avatars = Speech::Synthesis->InstalledAvatars( engine => $engine );
	
        my $ss = Speech::Synthesis->new(
					engine => 'Festival', 
					avatar => undef, language => 'es', 
					voice => 'JuntaDeAndalucia_es_pa_diphone', 
					async => 0, 
				       );
	    $ss->speak( $_[0] || "test" );
}

1;
