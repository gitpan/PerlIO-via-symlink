#!/usr/bin/perl
use Test::More tests => 5;
use PerlIO::via::symlink;
use strict;

my $fname = 'symlink-test';
unlink ($fname);

open my $fh, '>:via(symlink)', $fname or die $!;
print $fh "link foobar";
close $fh;
ok (-l $fname);
is (readlink $fname, 'foobar');
unlink ($fname);

eval {
open my $fh, '>:via(symlink)', $fname or die $!;
print $fh "foobar";
close $fh or die $!;
};
ok ($@ =~ m'Invalid argument');

open $fh, '<:via(symlink)', $fname;
ok ($! =~ m'Invalid argument');

eval {
open my $fh, '>:via(symlink)', $fname or die $!;
`touch $fname`;
print $fh "link foobar";
close $fh or die $!;
};
ok ($@ =~ m'File exists');
