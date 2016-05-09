#!/usr/bin/env perl


use strict ;
use warnings ;

# this isn't a full-blown parser (yet)
# what it will do is simply break apart by empty new lines,
# outputting to a given directory, using either a md5sum of
# the stanza or preferably a normalized version of the title if
# found.

# for now I'm running identify, eliminating any stanzas that seem
# only partially in another template

# so to prepare a config file, copy it, then remove anything
# but the stanzas (so LogFormat, etc).

use Digest::MD5 qw(md5_hex);
use File::Spec ;

my $config_file_path = $ARGV[0] ;
my $output_dir_path  = $ARGV[1] ;

if( !( -e $config_file_path ) ){
    die "$config_file_path does not exist" ;
}
if( !( -e $output_dir_path ) ){

    mkdir $output_dir_path ;
}



my $IN_TEMPLATE_STATE = 0 ;
my $BETWEEN_TEMPLATE_STATE = 1;
my $BAD_TEMPLATE = 2 ;
my $state = 1 ;

open my $config_fh, '<', $config_file_path or die "Issue opening $config_file_path $!" ;

my $title = '' ;
my $buffer = '' ;
CONFIG: while( my $line = <$config_fh> ) {

    chomp( $line ) ;
    
    if($state == $BETWEEN_TEMPLATE_STATE && $line =~ /^\s*$/ ) { 
        next CONFIG ;
    }
    elsif($state == $BETWEEN_TEMPLATE_STATE) {
        # we saw content, switch to next mode
        $state = $IN_TEMPLATE_STATE ;

        $title  = '' ;
        $buffer = '' ;
    }

    if( $state == $IN_TEMPLATE_STATE && $line =~ /^\s*$/ ) {
        
        if($buffer ne '') {
            create_template_file($output_dir_path, $title, $buffer );
            
        }
        
        
        $state = $BETWEEN_TEMPLATE_STATE ;
        next CONFIG ;


    }
    elsif( $state == $IN_TEMPLATE_STATE && $line =~ /### in template #/ ) {
        $state = $BAD_TEMPLATE ;
    }
    elsif( $state == $IN_TEMPLATE_STATE ) {
        $buffer .= $line . "\n" ;
        if( $buffer =~ /^\s*T(?:ITLE)? (.*)$/ ) {
            $title = normalize_title( $1 ) ;
        }
    }

    if($BAD_TEMPLATE && $line =~ /^\s*$/) {
        $state = $BETWEEN_TEMPLATE_STATE ;
    }
    
    

}
    
sub create_template_file {
    my $output_dir_path = shift ;
    my $title           = shift ;
    my $contents        = shift ; 

    if( !defined( $title ) || $title =~ /^\s*$/ ) {
        $title = md5_hex( $contents ) ;
    }

    $title .= '.template' ;

    my $output_path  = File::Spec->catfile( $output_dir_path,
                                            $title ) ;
        

    my $template_fh ;
    unless( (open $template_fh, '>', $output_path) ) {
        warn "Couldn't write to $output_path $1";
        next CONFIG ;
    } ;
    

    print $template_fh $contents ;
    close($template_fh) ;
    
}

sub normalize_title {

    my $raw_title = shift ;

    $raw_title =~ s/[^\w]/_/g;
    $raw_title = lc($raw_title );
    $raw_title =~ s/__+/_/g ;
    
    return $raw_title ;
    
}
    
