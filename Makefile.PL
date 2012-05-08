use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Kakapo',
    AUTHOR              => q{Joel Gomez <joelgomezb@gmail.com>},
    VERSION_FROM        => 'lib/Kakapo.pm',
    ABSTRACT_FROM       => 'lib/Kakapo.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'gpl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Speech::Synthesis' => 0,
        'Gtk2::Ex::Simple::List' => 0,
        'Gtk2::GladeXML' => 0,
        'Config::General' => 0,
        'File::Slurp' => 0,
        'Encode' => 0,
        'Exporter' => 0,
        'File::Temp' => 0,
        'Switch' => 0,
        'IO::File' => 0,
        'File::MimeInfo' => 0,
        'OpenOffice::OODoc' => 0,
        'Text::Extract::Word' => 0,
        'Locale::gettext' => 0,
        'IO::Socket' => 0,
        'Log::Log4perl' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Kakapo-*' },
);

#Install Depends poppler-utils festival ffmpeg lame festvox-kallpc16k
