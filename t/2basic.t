#!/usr/bin/perl
use Test::More tests => 9;
use PerlIO::via::symlink;
use strict;

my $fname = 'symlink-test';
unlink ($fname);
open my $fh, '+>:via(symlink)', $fname;
ok ($! =~ m'Invalid argument');

open $fh, '>:via(symlink)', $fname or die $!;
print $fh "link foobar";
close $fh;
ok (-l $fname);
is (readlink $fname, 'foobar');

open $fh, '<:via(symlink)', $fname or die $!;
is (<$fh>, 'link foobar', 'read');
seek $fh, 0, 0;
is (<$fh>, 'link foobar', 'read');

unlink ($fname);

eval {
open my $fh, '>:via(symlink)', $fname or die $!;
print $fh "foobar";
close $fh or die $!;
};
ok ($@ =~ m'Invalid argument');

open $fh, '<:via(symlink)', $fname;
ok ($! =~ m'Bad file descriptor');

eval {
open my $fh, '>:via(symlink)', $fname or die $!;
`touch $fname`;
print $fh "link foobar";
close $fh or die $!;
};
ok ($@ =~ m'File exists');

open $fh, '<:via(symlink)', $fname;
ok ($! =~ m'Bad file descriptor');
