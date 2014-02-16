#!/usr/bin/perl -w

#  symbolicate.pl
#  Symbolicate
#
#  Created by John Holdsworth on 16/02/2014.
#  Copyright (c) 2014 John Holdsworth. All rights reserved.

use IPC::Open2;
use strict;

#print "h\nh\nh\nh\nh\nh\n"; die ">>> @ARGV";

my ($crash, $archive) = @ARGV;
my ($app, $ident, $pid, $llin, $llout);

open CRASH, "< $crash" or die "Could not open '$crash' as: $!";

while ( my $line = <CRASH> ) {
    chomp $line;
    if ( $line =~ m@^Path:.*/MacOS/([^/]+)$@ ) {
        $app = $1;

        chomp( my $binary = `find '$archive' -regex '.*/MacOS/$app'` );
        chomp( my $symbol = `find '$archive' -regex '.*/DWARF/$app'` );

        system "rm -rf tmp && mkdir tmp && cd tmp && ln -s '$binary' . && ln -s '$symbol' $app.dSYM";
        $pid = open2 $llout, $llin, "cd tmp; lldb $app" or die "Could not open lldb";
        #warn ">>>".
        <$llout>;
        sleep 1;
    }
    elsif ( $line =~ /^Identifier:\s+(.*)/ ) {
        $ident = $1;
    }
    elsif ( $ident and my ($prefix, $addr) = $line =~ /^(\d+\s+$ident\s+)(\S+)/ ) {
        print $llin "image lookup -v --address $addr\n";
        flush $llin;
        #warn ">>".
        <$llout>;

        my ($ch, $summary);
        while( read $llout, $ch, 1 and ($ch ne "(" and $ch ne "\n" or
            $ch eq "\n" and read $llout, $ch, 1 and $ch ne "(") and my $out = <$llout> ) {
                ($summary) = $out =~ /Summary: (.*)/ if !$summary;
                #print ">".$out;
        }

        read $llout, $ch, length "lldb) ";
        $line = "$prefix$summary";
    }

    print "$line\n";
}

print $llin "quit\n";
waitpid( $pid, 0 );
