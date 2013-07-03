#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# lg_compare.pl                   falk@lormoral
#                    01 Jul 2013

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

lg_compare.pl

=head1 USAGE

  perl lg_compare.pl --gold=${NEO_TAGGER_TEST_SENT} neo_test_lg.tagged

=head1 DESCRIPTION

 Compares the pos tagging produced by the lg tagger with the part-of-speech tags given in the gold file (for neologisms recorded there).

The pos tagging produced by Lg. The format is the following :

 1	1	NC    <<- sentence id (S_1 in gold)

 Son	son	DET                                  | tagged words
 appétit	appétit	NC                           | one word per line
 institutionnel	institutionnel	ADJ                  |
 est	être	V
 NEO	Neo	NPP
 abracadabrantesquement	abracadabrantesquement	ADV
 NEO	Neo	NPP
 vorace	vorace	ADJ
 .	.	PONCT

 2	2	DET

 Ce	ce	PRO
 que	que	PROREL
 tu	tu	CLS

  ....


=head1 OPTIONS

=over

=item gold XML file containing gold pos assignments for neologisms.

=back

=cut


my %opts = (
	    'gold' => '',
	   );

my @optkeys = (
	       'gold=s',
	      );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

unless (@ARGV) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use XML::LibXML;

my $dom = XML::LibXML->load_xml(
  location => $opts{gold},
  );

my %gold;

foreach my $entry ($dom->findnodes('//entry')) {
  my $word_el = ($entry->findnodes('word'))[0];
  my $pos = $word_el->getAttribute('pos');
  
  foreach my $s ($entry->findnodes('.//s')) {
    my @neo = map { $_->textContent() } $s->findnodes('neologisme');
    my $s_id = $s->getAttribute('id');
    foreach my $word (@neo) {
      $gold{$s_id}->{$word}->{$pos}++;
    }
  }
}

my %lg;

open (my $fh, '<:encoding(utf-8)', $ARGV[0]) or die "Couldn't open $ARGV[0] for input: $!\n";

my $line = <$fh>;

my ($s_nbr, undef) = split(/\t/, $line);
my $s_id = "S_$s_nbr";

$line = <$fh>;

my @sent;

use List::MoreUtils qw(indexes natatime);

while ($line = <$fh>) {
  if ($line =~ m{ \A \s* \z }xms) {
    $line = <$fh>;
    if (defined($line)) {
      if (my $new_s_id = ($line =~ m{ \A (\d+) \s }xms)[0]) {
	$line = <$fh>;
	if ($line =~ m{ \A \s* \z }xms) {
	  if ($s_id) {
	    if (@sent) {
	      # print STDERR Dumper(\@sent);
	      my @neo_indexes = indexes { $_->[0] eq 'NEO' } @sent;
	      my $it = natatime 2, @neo_indexes;
	      while (my @pair = $it->()) {
		my $word = join(' ', map { $_->[0] } @sent[$pair[0]+1 .. $pair[1]-1]);
		my $pos = join(' ', map { $_->[1] } @sent[$pair[0]+1 .. $pair[1]-1]);
		$lg{$s_id}->{$word}->{$pos}++;
	      }
	    } else {
	      print STDERR "No sentence for $s_id\n";
	    }
	  }
	  $s_id = "S_$new_s_id";
	  @sent = ();
	}
      } else {
	chomp($line);
	my ($word, $pos) = split(/\t/, $line);
	push(@sent, [$word, $pos]);
      }
    }
  } else {
    chomp($line);
    my ($word, $pos) = split(/\t/, $line);
    push(@sent, [$word, $pos]);
  }
}

if ($s_id) {
  if (@sent) {
    # print STDERR Dumper(\@sent);
    my @neo_indexes = indexes { $_->[0] eq 'NEO' } @sent;
    my $it = natatime 2, @neo_indexes;
    while (my @pair = $it->()) {
      my $word = join(' ', map { $_->[0] } @sent[$pair[0]+1 .. $pair[1]-1]);
      my $pos = join(' ', map { $_->[1] } @sent[$pair[0]+1 .. $pair[1]-1]);
      $lg{$s_id}->{$word}->{$pos}++;
    }
  } else {
    print STDERR "No sentence for $s_id\n";
  }
}

close $fh;

foreach my $s_id (map { $_->[0] }
		  sort { $a->[1] <=> $b->[1] } 
		  map { [$_, /S_(\d+)/ ] }  keys %gold) {

  print "$s_id\n";
  foreach my $word (sort keys %{ $gold{$s_id} }) {
    foreach my $pos (sort keys %{ $gold{$s_id}->{$word} }) {
      print "GOLD: $word, $pos, $gold{$s_id}->{$word}->{$pos}\n";
    }
  }

  if ($lg{$s_id}) {
    foreach my $word (sort keys %{ $lg{$s_id} }) {
      foreach my $pos (sort keys %{ $lg{$s_id}->{$word} }) {
	print "LG: $word, $pos, $lg{$s_id}->{$word}->{$pos}\n";
      }
    }
  } else {
    print "No Lg tagging for $s_id\n";
  }


}

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
