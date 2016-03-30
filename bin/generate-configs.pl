#!/usr/bin/env perl

use strict ;
use warnings ;

use Text::Template ;
use Config::General ;
use File::Spec ;


########################################
##  Start config setup

my $conf = Config::General->new('ezproxy-collaborate.cfg');
my %config = $conf->getall ;

## End of config setup

########################################
##  Start stanza config setup

# first go approach will be to have all the stanza configurations in
# one file and the templates in separate files.
#
# might change to have a config directory w/ skeleton files


my $stanzas_conf =  Config::General->new('stanzas.cfg');
my $stanzas_config_ref = { $stanzas_conf->getall } ;

## End of stanza setup


# this is the include file ...to iclude

open my $include_listing, '>', $config{INCLUDE_FILE}
    or die "Could not open $config{INCLUDE_FILE} $!" ;


opendir(my $template_dir,  $config{TEMPLATE_DIR}) or die "Can't open template directory ( $config{TEMPLATE_DIR} ) $!" ;

FILE: while( my $filepath = readdir( $template_dir ) ) {

    if( $filepath !~ /\.template$/) {
        next FILE ;
    }

    my $id = $filepath ;
    $id =~ s/(_i)?\.template// ;
    
    # Setup the template
    my $template_filepath
        = File::Spec->catfile( $config{ TEMPLATE_DIR },
                               $filepath ) ;
    my $template
        = Text::Template->new( TYPE => 'FILE',
                               SOURCE => $template_filepath ) ;


    if( $filepath =~ /_i.template$/ && !defined($stanzas_config_ref->{ $id } ) ) {
        warn "Institutional information needed for $id, but nothing found in stanza.cfg\n";
    }
    
    my $text = $template->fill_in(  HASH => $stanzas_config_ref->{ $id }    ) ;

    
    # Setup the output file
    my $target_filepath_init = $filepath ;
    $target_filepath_init =~ s/\.template$/.stanza/ ;

    my $target_filepath = File::Spec->catfile($config{CONFIG_DIR},
                                           $id . '.stanza') ;

    open my $target_fh, '>', $target_filepath or die "Couldn't open $target_filepath for writing $! " ;
    
    print $target_fh $text ;
    print $include_listing "IncludeFile $target_filepath\n" ; 
}




