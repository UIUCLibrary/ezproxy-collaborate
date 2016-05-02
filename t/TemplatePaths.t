#!/usr/bin/env perl

use strict ;
use warnings ;

use Test::More ;

use FindBin ;

use lib "$FindBin::Bin/../lib" ;
use lib "$FindBin::Bin/lib" ;

use TemplatePaths ;


my $templates_ref
    = TemplatePaths::template_paths_array({vendor_dir => 't/vendor',
                                           local_dir  => 't/local',
                                       });
my $expected_ref = [

    {name => '05_smart.template',
     path => 't/vendor/oclc/05_smart.template'},

    {name => '05_test1.template',
     path => 't/local/05_test1.template'},

    {name => '05_test3.template',
     path => 't/local/05_test3.template'},

    {name => 'get.template',
     path => 't/local/get.template'},

    {name => 'test.template',
     path => 't/vendor/oclc/test.template'},

    {name => 'test1.template',
     path => 't/vendor/oclc/test1.template'},


    {name => 'test2.template',
     path => 't/vendor/testing_journals/test2.template'},

] ;

use Data::Dumper ;

#diag( "Results of call: " . Dumper( $templates_ref ) . "\n\n") ;
#diag( "Results of call: " . Dumper( $expected_ref ) . "\n\n") ;

is_deeply( $templates_ref, $expected_ref ) ;



done_testing() ;
