#!/usr/bin/env perl

#
# A report that will get every title line and attempt
# to get all the urls for that stanza, comma-delimited.
#
# so title\turl1,url2,url3

use strict ;
use warnings ;

use EzproxyConfig qw(:all) ;

my $config_file_path = $ARGV[0] ;
if( !( -e $config_file_path ) ){
    die "$config_file_path does not exist" ;
}


use EzproxyStanzaChunker ;

open my $config_fh,'<',$config_file_path or die "Couldn't open $config_file_path $!" ;
my $chunker = EzproxyStanzaChunker->new($config_fh) ;

print join("\t", 'Title', 'Line # stanza starts', 'urls in stanza') . "\n" ; 
while( my $stanza = $chunker->next() ) {

    my $contents = $stanza->{contents} ;

    # probably could have the chunker do this..

    my @urls = () ;
    foreach my $line (split("\n", $stanza->{contents} ) )  {
        if(contains_url($line) && ! all_whitespace( normalize_url_content( $line ) )  ) {
            push(@urls,  normalize_url_content( $line ) ) ;
        }
    }
    print join("\t",
               $stanza->{title_raw},
               $stanza->{starts_at},
               join(",", @urls) ) . "\n" ;
    
}
