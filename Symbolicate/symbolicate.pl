#!/usr/bin/perl -w

#  symbolicate.pl
#  Symbolicate
#
#  Created by John Holdsworth on 16/02/2014.
#  Copyright (c) 2014 John Holdsworth. All rights reserved.

use IPC::Open2;
use strict;

my ($crash, $archive) = @ARGV;
my ($app, $ident, $pid, $llin, $llout);

open CRASH, "< $crash";
my ($loadAddress) = join( '', <CRASH>) =~ /Binary Images:\s+(\S+)/;

warn "$crash, $archive, $loadAddress\n";

open CRASH, "< $crash" or die "Could not open '$crash' as: $!";

while ( my $line = <CRASH> ) {
    chomp $line;

    if ( ($app) = $line =~ m@^Process:\s+(\S+)@ ) {
        chomp( my $binary = `find '$archive' -regex '.*/MacOS/$app'` );
        chomp( my $symbol = `find '$archive' -regex '.*/DWARF/$app'` );

        warn "$binary, $symbol\n";

        system "rm -rf tmp && mkdir tmp && cd tmp && ln -s '$binary' . && ln -s '$symbol' $app.dSYM";
        $pid = open2 $llout, $llin, "cd tmp; lldb $app" or die "Could not open lldb";
        <$llout>;
        <$llout>;
        print $llin "target modules load --file $app __TEXT $loadAddress\n";
        flush $llin;
        <$llout>;
        <$llout>;
        sleep 1;
    }
    elsif ( $line =~ /^Identifier:\s+(.*)/ ) {
        $ident = $1;
    }
    elsif ( $ident and my ($prefix, $addr) = $line =~ /^(\d+\s+$ident\s+)(\S+)/ ) {
        print $llin "image lookup --address $addr\np 1\n";
        flush $llin;
        warn "??".<$llout>;

        my ($ch, $summary);
        while( read $llout, $ch, 1 and ($ch ne "(") and my $out = <$llout> ) {
                warn ">> $out";
                ($summary) = $out =~ /Summary: (.*)/ if !$summary;
                #print ">".$out;
        }

        $line = "$prefix$summary";
        <$llout>;
        <$llout>;
    }

    print "$line\n";
}

print $llin "quit\n";
waitpid( $pid, 0 );
