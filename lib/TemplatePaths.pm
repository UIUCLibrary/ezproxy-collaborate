#!/usr/bin/env perl

use strict ;
use warnings ;

package TemplatePaths ;

# We need to organize this into an actual perl
# project at some point

# goal of this module is to have a mapping of
# all the templates, with templates from the local
# folder overriding any temp

# not sure yet if I should ignore numerics, might be good idea,
# might be bad idea

# also for now just returning an array of
# hashref, coiuld make this more OOP
# by having a "TemplatePath" object w/ name and path
# and this being a array-like structure

# set up config - mainly directories


# start in vendor, go into each directory
# have last matching path overwrite by having hash
#
# then go to local
# the order by name

use File::Spec ;


## End of config setup


sub template_paths_array {

    my $args_ref = shift ;

    my $vendor_dir ;
    my $local_dir  ;

    if(    defined($args_ref)
       &&  (defined( $args_ref->{vendor_dir} ) || defined( $args_ref->{local_dir} ) ) ) { 
        $vendor_dir =  $args_ref->{vendor_dir} ;
        $local_dir  =  $args_ref->{local_dir} ;
    }
    else {
        use Config::General ;

        my $conf = Config::General->new('ezproxy-collaborate.cfg');
        my %config = $conf->getall ;
        
        $vendor_dir = $config{TEMPLATE_VENDOR_DIR};
        $local_dir  = $config{TEMPLATE_LOCAL_DIR};

    }
    
    
    
    my $path_mappings = {} ;
    opendir my $vendor_root_dir, $vendor_dir
        or die "Couldn't open $vendor_dir $!" ;
    
    # for each directory in vendor directory, add to path mapping
    my @filepaths = reverse readdir( $vendor_root_dir ) ;
    while( my $possible_vendor_dir = shift @filepaths ) {
        if(   $possible_vendor_dir ne '.'
           && $possible_vendor_dir ne '..'
           && -d File::Spec->catdir($vendor_dir, $possible_vendor_dir) ) {
            #print "Will process $possible_vendor_dir \n" ;
            add_paths( $path_mappings, File::Spec->catdir($vendor_dir, $possible_vendor_dir ) );
        }
    }
    
    
    if(-e $local_dir ) {
        add_paths( $path_mappings, $local_dir ) ;
    }
    
    my @template_paths = map {{ name => $_,
                                    path => $path_mappings->{$_} }
                          } sort keys %{$path_mappings} ;

    return @template_paths ;
}

sub add_paths {
    my $path_mappings = shift ;
    my $dirpath = shift ;

    
    opendir my $dir, $dirpath or die "Couldn't open $dirpath $!" ;
    while(my $filepath = readdir( $dir ) ) {
        if( $filepath ne '.' && $filepath ne '..' && $filepath =~ /.template/) {
            $path_mappings->{ $filepath } = File::Spec->catfile( $dirpath, $filepath) ;
        }
    }

}

1;

