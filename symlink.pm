package PerlIO::via::symlink;
use 5.008;
use warnings;
use strict;
our $VERSION = '0.01';

=head1 NAME

PerlIO::via::symlink - PerlIO layers for create symlinks

=head1 SYNOPSIS

 open $fh, '>:via(symlink)', $fname;
 print $fh "link foobar";
 close $fh;

=head1 DESCRIPTION

The PerlIO layer C<symlink> allows you to create a symbolic link by
writing to the file handle.

You need to write C"link $name" to the file handle. If the format does
not match, C<close> will fail with EINVAL.

Currently only writing is supported.

=cut

use Errno qw(EINVAL);
use Symbol qw(gensym);

sub PUSHED {
    $! = EINVAL, return -1
	unless $_[1] eq 'w';
    bless gensym(), $_[0];
}

sub OPEN { ${*{$_[0]}}{fname} = $_[1] }

sub WRITE {
    my $buf = $_[1];
    ${*{$_[0]}}{content} .= $_[1];
    return length($buf);
}

sub CLOSE {
    my ($link, $fname) = @{*{$_[0]}}{qw/content fname/};
    $link =~ s/^link // or $! = EINVAL, return -1;
    symlink $link, $fname or return -1;
    return 0;
}

=head1 TEST COVERAGE

 ----------------------------------- ------ ------ ------ ------ ------ ------
 File                                  stmt branch   cond    sub   time  total
 ----------------------------------- ------ ------ ------ ------ ------ ------
 blib/lib/PerlIO/via/symlink.pm       100.0  100.0    n/a  100.0  100.0  100.0
 Total                                100.0  100.0    n/a  100.0  100.0  100.0
 ----------------------------------- ------ ------ ------ ------ ------ ------

=head1 AUTHORS

Chia-liang Kao E<lt>clkao@clkao.orgE<gt>

=head1 COPYRIGHT

Copyright 2004 by Chia-liang Kao E<lt>clkao@clkao.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut

1;
