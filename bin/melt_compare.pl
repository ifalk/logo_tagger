#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# melt_compare.pl                   falk@lormoral
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

melt_compare.pl

=head1 USAGE

  perl melt_compare.pl --gold=${NEO_TAGGER_TEST_SENT} neo_test_melt.tagged

=head1 DESCRIPTION

 Compares the pos tagging produced by the melt tagger with the part-of-speech tags given in the gold file (for neologisms recorded there).

=head1 REQUIRED ARGUMENTS

The pos tagging produced by MElt. The format is the following :

Sentence number (S_1 in gold file):
 1/DET 

Tagged sentence:
 Son/DET appétit/NC institutionnel/ADJ est/V abracadabrantesquement/ADV vorace/ADJ ./PONCT <<- tagged sentence

 2/DET
 Ce/PRO que/PROREL tu/VPP fais/V là/ADV n'/ADV est/V pas/ADV accessibilisable/VPP en/P tant/ADV que/CS tel_./ADV tel_./PONCT
 ...

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

my %melt;

open (my $fh, '<:encoding(utf-8)', $ARGV[0]) or die "Couldn't open $ARGV[0] for input: $!\n";

my $s_id;
my @comp;
while (my $line = <$fh>) {
  chomp($line);
  if (my ($s_nbr) = ($line =~ m{ \A (\d+) \/[A-Z]+ \z }xms)) {

    if ($s_id) {

      if (@comp) {
	my $seq = join(' ', @comp);
	my (@word_pos) = ($seq =~ m{ NEO\/[A-Z]+ \s+ (.*?) \s+ NEO }xmsgi);
	if (@word_pos) {
	  foreach my $wp (@word_pos) {
	    my @wps = split(/\s+/, $wp);
	    my @mwe;
	    foreach my $pair (@wps) {
	      my ($word, $pos) = split(/\//, $pair);
	      push(@mwe, [$word, $pos]);
	    }
	    my $word = join(' ', map { $_->[0] } @mwe);
	    my $pos = join(' ', map { $_->[1] } @mwe);
	    $melt{$s_id}->{$word}->{$pos}++;
	  }
	} else {
	  print STDERR "No neologism for $s_id:\n";
	  print STDERR $seq, "\n";
	}
	@comp = ();
      } else {
	print STDERR "No pos tagging for $s_id\n";
      }
    }
    $s_id = "S_$s_nbr";
  } else {
    push(@comp, $line);
  }
}

#### last record
if ($s_id) {
  
  if (@comp) {
    my $seq = join(' ', @comp);
    my (@word_pos) = ($seq =~ m{ NEO\/[A-Z]+ \s+ (.*?) \s+ NEO }xmsgi);
    if (@word_pos) {
      foreach my $wp (@word_pos) {
	my @wps = split(/\s+/, $wp);
	my @mwe;
	foreach my $pair (@wps) {
	  my ($word, $pos) = split(/\//, $pair);
	  push(@mwe, [$word, $pos]);
	}
	my $word = join(' ', map { $_->[0] } @mwe);
	my $pos = join(' ', map { $_->[1] } @mwe);
	$melt{$s_id}->{$word}->{$pos}++;
      }
    } else {
      print STDERR "No neologism for $s_id:\n";
      print STDERR $seq, "\n";
    }
    @comp = ();
  } else {
    print STDERR "No pos tagging for $s_id\n";
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

  if ($melt{$s_id}) {
    foreach my $word (sort keys %{ $melt{$s_id} }) {
      foreach my $pos (sort keys %{ $melt{$s_id}->{$word} }) {
	print "MELT: $word, $pos, $melt{$s_id}->{$word}->{$pos}\n";
      }
    }
  } else {
    print "No MElt tagging for $s_id\n";
  }


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
