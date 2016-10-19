

package EzproxyConfig ;

require Exporter ;
@ISA = qw(Exporter) ;
@EXPORT_OK = qw(normalize_ezproxy_line
                ezproxy_comment_line
                ezproxy_option_line
                ezproxy_form_variable_line
                all_whitespace
                contains_url
                normalize_url_content
           ) ;
%EXPORT_TAGS = ( all => \@EXPORT_OK) ;

sub normalize_ezproxy_line {

    my $line = shift ;
    # do some normalization to make comparison a bit easier
    #
    # for now, chompa nd just remove all whitespace 

    chomp( $line ) ;
    $line =~ s/\s//g;

    return $line ;
}

sub ezproxy_comment_line {

    my $line = shift ;

    if( $line =~ /^\s*#/ ) {
        return 1;
    }
    return 0 ;
}


sub ezproxy_option_line {

    my $line = shift ;

    if( $line =~ /Option/ ) {
        return 1;
    }
    return 0 ;
}

sub ezproxy_form_variable_line {

    my $line = shift ;

    if( $line =~ /FormVariable/ ) {
        return 1;
    }
    return 0 ;
}


sub all_whitespace {
    my  $line = shift ;

    if( $line =~ /^\s*$/ ) {
        return 1 ;
    }
    return 0 ;
}

# NOT the same as a url ezproxy stanza, instead
# will get any of the domain, url, or host stanza liness...hopefully
#
# 
#URL
#Host
#HostJavascript
#Domain
#DomainJavascript
# it does not yet sanity check, so assumes above are urls 
sub contains_url {

    my $line = shift ;
    
    if(   $line =~ /^\s*u(rl)? /i
       || $line =~ /^\s*h(ost)? /i
       || $line =~ /^\s*h(ostjavascript)? /i
        || $line =~ /^\s*hj /i
       || $line =~ /^\s*d(omain)? /i
       || $line =~ /^\s*dj /i
       || $line =~ /^\s*d(omainjavascript)? /i ) {

        return 1 ;
        
    }
    return 0 ;
    
}


sub normalize_url_content {
    
    my $line = shift ;

    # we could use the code to identify
    # to be more precise 
    # ie    $line =~ s/^\s*u(rl)? //i ;
    $line =~ s/^\s*.+\s/ /;

    $line =~ s/https?:\/\///g;

    $line =~ s/^\s*//g;
    $line =~ s/\s*$//g;
    
    
    return $line ;
}

    

        
               1;
