#!/usr/bin/env perl

use strict ;
use warnings ;

use File::Spec ;

use EzproxyConfig qw(:all) ;





##
## This script will take in an ezproxy file and print to standard
## urls that appear multiple times in the file
## w/ url and line positions. NOTE: for now not examining
## multiple config files
#
# ./identify_redudant_information.pl config.txt  config.txt


my $ezproxy_config_filepath = $ARGV[0] ;

open my $ezproxy_config, '<', $ezproxy_config_filepath or die "Couldn't open $ezproxy_config_filepath $!" ;


#URL
#Host
#HostJavascript
#Domain
#DomainJavascript

my $line_pos = 1 ;
    my %normalized_lines = () ;

while( my $line = <$ezproxy_config>) {

    # have some sort of threshold?
    
    chomp ($line) ;
    if( contains_url( $line ) ) {
        my $normalized_content = normalize_url_content( $line) ;
        if( !all_whitespace( $normalized_content ) ) {
#            print "Adding $line_pos: $normalized_content \n";
            push(@{$normalized_lines{ $normalized_content }}, $line_pos) ;
        }
    }
    $line_pos++ ;

}

foreach my $normalized_url_content (sort keys %normalized_lines) {
    if( scalar(@{$normalized_lines{ $normalized_url_content } } ) > 1 ) {


        my @line_pos = @{$normalized_lines{ $normalized_url_content } } ;
        # probably some clever way to use reduce here...
        my @distances = () ;
        my $last_pos = $line_pos[0] ;
        for( my $i = 1 ; $i< @line_pos ; $i++) {

            my $current_pos = $line_pos[$i] ;
            push(@distances, $current_pos - $last_pos) ;
            $last_pos = $current_pos ;
            
        }
        
        print "$normalized_url_content:\t"
            . join(',', @line_pos)
            ."\t"
            . join(',',@distances)
             . "\n" ;
    }
}
    
