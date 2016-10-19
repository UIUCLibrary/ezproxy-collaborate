#!/usr/bin/env perl


package EzproxyStanzaChunker ;

use strict ;
use warnings ;

use EzproxyConfig qw(:all) ;


our $IN_TEMPLATE_STATE = 0 ;
our $BETWEEN_TEMPLATE_STATE = 1;
our $BAD_TEMPLATE = 2 ;


#should play around with class lite or something similar
sub new {

    my $class = shift ;

    my $filehandle = shift ;

    if(!defined($filehandle)) {
        die "Need a filehandle object" ;
    }
    
    my $self = {
        state         => 1 ,
        filehandle    => $filehandle,
        hasNext       => 1,
        titlecount    => 0,
        last_titleraw => '',
        buffer        => '',
        linecount     => 0 ,
    } ;

    bless $self, $class ;
    return $self ;
}

# for now return buffer, at some point wrap around with an EzproxyStanza object
sub next {
    
    my $self = shift ;
    
    my $config_fh = $self->{filehandle} ;
    
  CONFIG: while( my $line = <$config_fh> ) {

        $self->{linecount}++ ;
        chomp( $line ) ;
        
        if($self->{state} == $BETWEEN_TEMPLATE_STATE && $line =~ /^\s*$/ ) { 
            next CONFIG ;
        }
        elsif($self->{state} == $BETWEEN_TEMPLATE_STATE) {
            # we saw content, switch to next mode
            $self->{state} = $IN_TEMPLATE_STATE ;
        }
        
        

        # purposefully not elseif


        # going to disable this for now, should make option
        #if( $self->{state} == $IN_TEMPLATE_STATE && $line =~ /^\s*$/ ) {
        #    # hit a line with only whitespace, assuming stanza has ended....
        #    if($self->{buffer} ne '') {
        #
        #        my $stanza = { title_raw  => $self->{title_raw},
        #                       title_norm => normalize_title($self->{title_norm}),
        #                       contents   => $self->{buffer} };
        #        #REFACTOR...pull into method
        #        $self->{title_norm} = '' ;
        #        $self->{title_raw}  = '' ;
        #        $self->{buffer}     = '' ;
        #        $self->{titlecount} = 0 ;
        #        $self->{state} = $BETWEEN_TEMPLATE_STATE ;                
        #        
        #        return $stanza ;
        ##    }
        #}
        ## originally elsif, but disabled initial if
        if( $self->{state} == $IN_TEMPLATE_STATE && $line =~ /### in template #/ ) {
            $self->{state} = $BAD_TEMPLATE ;
        }
        elsif( $self->{state} == $IN_TEMPLATE_STATE ) {
            
            if( $line =~ /^\s*T(?:ITLE)? (.*)$/ && $self->{titlecount} == 0) {
                $self->{title_raw} = $1 ;
                $self->{title_norm} = normalize_title( $self->{title_raw} ) ;
                $self->{titlecount}++ ;
                              
                $self->{buffer} = $line . "\n";
            }
            elsif ($line =~ /^\s*T(?:ITLE)? (.*)$/ && $self->{titlecount} > 0) {
               
                # were in stanza and hit another title, start new stanza
                my $stanza = { title_raw  => $1,
                               title_norm => normalize_title($self->{$1}),
                               contents   => $self->{buffer},
                               starts_at  => $self->{stanza_starts_at},
                               } ;

                $self->{stanza_starts_at} = $self->{linecount} ;
                $self->{title_norm} = normalize_title( $line ) ;
                $self->{title_raw}  = $line ;
                $self->{buffer}     = $line . "\n" ;
                $self->{titlecount} = 1 ;
                
                return $stanza ;
            }
            else {
                $self->{buffer} .= $line . "\n" ;
            }
        }
        
        if($BAD_TEMPLATE && $line =~ /^\s*$/) {
            $self->{state} = $BETWEEN_TEMPLATE_STATE ;
        }
    }

        
    
    if( eof $self->{filehandle} ) {
        $self->{hasNext} = 0 ;
    }

    # means likely hit the end of the file, but didn't actually end the template
    if( $IN_TEMPLATE_STATE ) {
        return {
            title      => $self->{title_raw},
            title_norm => $self->{title_norm},
            contents   => $self->{buffer},
            starts_at  => $self->{stanza_starts_at},
        }
    }

}



    
