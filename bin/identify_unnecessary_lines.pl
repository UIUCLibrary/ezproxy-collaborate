#!/usr/bin/env perl

use strict ;
use warnings ;

##
## This script will take in an ezproxy file and print to standard
## out (for now) a copy with lines that appear in the conf.d/*stanza
## commented out w/
## ### in template
##
## This pretty rough yet, as stuff like secrets and not
## will still not work, and positional-dependent stanzas
## could cause issues. Meant ot make it easier to
## cleanup a file after switching to using this template system
##

use Config::General ;
use File::Spec ;

########################################
##  Start config setup

my $conf = Config::General->new('ezproxy-collaborate.cfg');
my %config = $conf->getall ;

## End of config setup


use EzproxyConfig qw(:all) ;

# question, use stanzas or templates? or either?

my $reference_lines = get_stanza_lines_ref( $config{ CONFIG_DIR } ) ;

my $ezproxy_filepath = $ARGV[0] ;

open my $ezproxy_fh, '<', $ezproxy_filepath or die("Could not open $ezproxy_filepath $!");

while( my $line = <$ezproxy_fh> ) {

    if( $reference_lines->{ normalize_ezproxy_line( $line ) }
       && ! ezproxy_comment_line( $line )
       && ! ezproxy_option_line( $line )
       && ! ezproxy_form_variable_line( $line ) 
       && ! all_whitespace( $line )

     ) {
        $line = "### in template # " . $line ;
    }

    print $line ;
}

sub get_stanza_lines_ref {

    my $conf_dirpath = shift; 

    opendir(my $conf_dir, $conf_dirpath) or die "Couldn't open $conf_dirpath $! ";

    my %lines = (); 
    POSSIBLETEMPLATE: while( my $filename = readdir( $conf_dir )) {

          if($filename !~ /\.stanza/ ) {
              next POSSIBLETEMPLATE ;
          }

          my $filepath = File::Spec->catfile($conf_dirpath,
                                             $filename );


          open my $fh, '<', $filepath or die "Could not open $filepath $!";
          while( my $line = <$fh>) {
              $lines{ normalize_ezproxy_line( $line ) } = 1  ;
          }
      }

    return \%lines ;
}

