#!/usr/bin/env perl

use strict ;
use warnings ;

use Text::Template ;
use Config::General ;
use File::Spec ;

use lib 'lib' ;
use lib '../lib' ;
use TemplatePaths ;


#######################################
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


#opendir(my $template_dir,  $config{TEMPLATE_DIR}) or die "Can't open template directory ( $config{TEMPLATE_DIR} ) $!" ;

my @template_filepaths = TemplatePaths::template_paths_array() ;

FILE: while( my $template_info = shift @template_filepaths ) {
    
#    if( $filepath !~ /\.template$/) {
#        next FILE ;
#    }
    
    my $id = $template_info->{name} ;
    $id =~ s/(_i)?\.template// ;
    
    # Setup the template
    my $template_filepath = $template_info->{path} ;

    my $template
        = Text::Template->new( TYPE => 'FILE',
                               SOURCE => $template_filepath ) ;


    if( $template_info->{name} =~ /_i.template$/ && !defined($stanzas_config_ref->{ $id } ) ) {
        warn "Institutional information needs to be added to stanza.cfg to correspond with the variables in the template file at $template_info->{path} \n";
    }
    
    my $text = $template->fill_in(  HASH => $stanzas_config_ref->{ $id }    ) ;

    if(! defined($text) ) {
        warn( $template_info->{path} . " seems to be an empty file, skipping " ) ;
        next FILE ;
    }
    
    # Setup the output file
    my $target_filepath_init = $template_info->{name} ;
    $target_filepath_init =~ s/\.template$/.stanza/ ;

    my $target_filepath = File::Spec->catfile($config{CONFIG_DIR},
                                           $id . '.stanza') ;

    open my $target_fh, '>', $target_filepath or die "Couldn't open $target_filepath for writing $! " ;
    
    print $target_fh $text ;
    print $include_listing "IncludeFile $target_filepath\n" ; 
}




