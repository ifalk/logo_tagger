#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# stanford_compare.pl                   falk@lormoral
#                    02 Jul 2013

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

stanford_compare.pl

=head1 USAGE

   

=head1 DESCRIPTION

Stub documentation for stanford_compare.pl, 

=head1 REQUIRED ARGUMENTS

=head1 OPTIONS

=cut

my %opts = (
  'gold' => '',
  'csv_out' => '',
  'tagset_out' => '',
  );

my @optkeys = (
  'gold=s',
  'csv_out:s',
  'tagset_out:s',
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
my %gold_sent;

foreach my $entry ($dom->findnodes('//entry')) {
  my $word_el = ($entry->findnodes('word'))[0];
  my $pos = $word_el->getAttribute('pos');
  
  foreach my $s ($entry->findnodes('.//s')) {
    my $sent = $s->textContent();
    my @neo = map { $_->textContent() } $s->findnodes('neologisme');
    my $s_id = $s->getAttribute('id');
    $gold_sent{$s_id} = $sent;
    foreach my $word (@neo) {
      $gold{$s_id}->{$word}->{$pos}++;
    }
  }
}

use List::MoreUtils qw(indexes);

my %stanf;
my %tagset;

my $sdom = XML::LibXML->load_xml(
  location => $ARGV[0],
  );

foreach my $s ($sdom->findnodes('//s')) {
  my $s_id = $s->getAttribute('id');
  my $tagging = $s->textContent();
  $tagging =~ s{ \A \s* }{}xms;
  my @wp = map { [ split(/_/, $_) ] } split(/\s+/, $tagging);
  foreach my $g_neo (keys %{ $gold{$s_id} }) {
    my @words = split(/\s+/, $g_neo);
    my @matches = indexes { $_->[0] =~ m{ \b $words[0] \b }xms } @wp;
    unless (@matches) {
      print STDERR $gold_sent{$s_id}, "\n";
      print STDERR Dumper(\@wp);
    }
    # print STDERR Dumper(\@matches);

    foreach my $neo_start (@matches) {

      my $neo_end = $neo_start+$#words;

      if ($neo_end != $neo_start) {
	next unless ($wp[$neo_end]->[0] =~ m{ \b $words[$#words] \b }xms); 
      }

      my $sf_word = join(' ', map { $wp[$_]->[0] } $neo_start .. $neo_end);
      my $sf_pos = join(' ', map { $wp[$_]->[1] } $neo_start .. $neo_end);
      $stanf{$s_id}->{$sf_word}->{$sf_pos}++;
      $tagset{$sf_pos}++;
    }
  }
}

my %gold_sf;


foreach my $s_id (map { $_->[0] }
		  sort { $a->[1] <=> $b->[1] } 
		  map { [$_, /S_(\d+)/ ] }  keys %gold) {

  print "$s_id\n";
  foreach my $word (sort { lc($a) cmp lc($b) } keys %{ $gold{$s_id} }) {
    foreach my $pos (sort keys %{ $gold{$s_id}->{$word} }) {
      push(@{ $gold_sf{$s_id}->{gold} }, [ $word, $pos ]);
      print "GOLD: $word, $pos, $gold{$s_id}->{$word}->{$pos}\n";
    }
  }

  if ($stanf{$s_id}) {
    foreach my $word (sort { lc($a) cmp lc($b) } keys %{ $stanf{$s_id} }) {
      foreach my $pos (sort keys %{ $stanf{$s_id}->{$word} }) {
	push(@{ $gold_sf{$s_id}->{tagger} }, [ $word, $pos ]);
	print "STANF: $word, $pos, $stanf{$s_id}->{$word}->{$pos}\n";
      }
    }
  } else {
    print "No Stanford tagging for $s_id\n";
  }


}


if ($opts{csv_out}) {

  if (open(my $fh, '>:encoding(utf-8)', $opts{csv_out})) {

    print $fh join("\t", qw(s_id g_word t_word g_pos t_pos correct?)), "\n";

    foreach my $s_id (map { $_->[0] }
		      sort { $a->[1] <=> $b->[1] } 
		      map { [$_, /S_(\d+)/ ] }  keys %gold_sf) {

      foreach my $wp_ref_index (0 .. $#{ $gold_sf{$s_id}->{gold} }) {

	my ($g_word, $g_pos) = @{ $gold_sf{$s_id}->{gold}->[$wp_ref_index] };
	my ($t_word, $t_pos) = @{ $gold_sf{$s_id}->{tagger}->[$wp_ref_index] };
	
	my $correct = 0;

	if (lc($g_pos) eq lc($t_pos)) {
	  $correct = 1;
	} elsif ($g_pos eq 'nom' and $t_pos =~ m{ \A N }xms) {
	  $correct = 1;
	} elsif ($g_pos eq 'adj' and $t_pos =~ m{ \A A }xms) {
	  $correct = 1;
	} elsif ($g_pos eq 'verbe' and $t_pos =~ m{ \A V }xms) {
	  $correct = 1;
	}

	print $fh join("\t", $s_id, $g_word, $t_word, $g_pos, $t_pos, $correct), "\n";
      }
    }
  } else {
    warn "Couldn't open $opts{csv_output} for output: $!\n";
  }
}

if ($opts{tagset_out}) {
  open(my $fh, '>:encoding(utf-8)', $opts{tagset_out}) or carp "Couldn't open $opts{tagset_out} for output: $!\n";

  foreach my $pos (sort keys %tagset) {
    print $fh $pos, "\n";
  }

  close $fh;
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
