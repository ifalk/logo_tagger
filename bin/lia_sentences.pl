#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# lia_sentences.pl                   falk@lormoral
#                    08 Jul 2013

use warnings;
use strict;
use English;

use Data::Dumper;
use Carp;
use Carp::Assert;

use Pod::Usage;
use Getopt::Long;

use utf8;

=head1 NAME

lia_sentences.pl

=head1 USAGE

   perl lia_sentences.pl tokenised text (according to lia)

=head1 DESCRIPTION

Splits a text, tokenised according to lia into sentences, i.e. each line is inserted between <<s>> and <</s>> markup. 

=head1 REQUIRED ARGUMENTS

The file containing text tokenised following LIA guidelines (i.e. words and punctuation characters are delimited by white spaces).

=head1 OPTIONS

=cut


my %opts = (
	    'an_option' => 'default value',
	   );

my @optkeys = (
	       'an_option:s',
	      );

unless (@ARGV) { pod2usage(2); };


unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

binmode(STDOUT, ':encoding(iso-8859-1)');
binmode(STDERR, ':utf8');

open (my $fh, "<:encoding(iso-8859-1)", $ARGV[0]) or die "Couldn't open $ARGV[0] for input: $!\n";

while (my $line = <$fh>) {
  print "<s>\n";

  my @words = split(/\s+/, $line);

  if ($words[0] =~ m{ S_\d+ }xms) {
    print $words[0], "\n";
  } else {
    print lc($words[0]), "\n";
  }
  foreach my $word (@words[1..$#words]) {
    print $word, "\n";
  }

  print "</s>\n";
}

close $fh;

1;





__END__

=head1 EXIT STATUS

=head1 CONFIGURATION

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

created by template.el.

It looks like the author of this script was negligent
enough to leave the stub unedited.


=head1 AUTHOR

Ingrid Falk, E<lt>E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Ingrid Falk

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
