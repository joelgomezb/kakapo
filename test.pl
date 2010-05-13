#!/bin/perl -w

use Speech::Synthesis;

my @voices = Speech::Synthesis->InstalledVoices(engine => 'Festival');
foreach (@voices){
   print "\n".$_->{id};
}
