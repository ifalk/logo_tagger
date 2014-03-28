#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# talismane_compare.pl                   falk@lormoral
#                    21 Mar 2014

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

talismane_compare.pl

=head1 USAGE

   perl talismane_compare.pl --gold=neo_index.pl talismane_test_melt.tagged


=head1 DESCRIPTION

Compares the pos tagging produced by the talismane tagger with the part-of-speech tags given in the gold file (for neologisms recorded there).

=head1 REQUIRED ARGUMENTS

The pos tagging produced by talismane. The format is the following:

 | index in sentence
 |       | token
 |       |      | pos tag
 |       |      |       | sentence id
 |       |      |       |       |  character offset
 v       v      v       v       v

 0	Son	DET	1	1	
 1	appétit	NC	1	5	
 2	institutionnel	ADJ	1	13	
 3	est	V	1	28	
 4	abracadabrantesquement	ADV	1	32	
 5	vorace	ADJ	1	55	
 6	.	PONCT	1	61	

 0	Ce	PRO	2	1	
 1	que	PROREL	2	4	
 2	tu	V	2	8	
 3	fais	V	2	11	
 4	là	ADV	2	16	


=head1 OPTIONS


=over

=item gold

Index file used to retrieve the gold tags and compare them with the tags produced by MElt. Format is a perl array with one entry - an array reference - for each gold sentence. The first element of each entry for a gold sentence is its sentence id, the next elements are an array reference [word, POS], for each neologism in the sentence.  

 $VAR1 = [
          [
            'S_1',
            [
              'abracadabrantesquement',
              'adv'
            ]
          ],
          [
            'S_2',
            [
              'accessibilisable',
              'adj'
            ]
          ],
          [
            'S_3',
            [
              'accessibilisable',
              'adj'
            ]
          ],
      ....


=back



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

my @gold_sent = @{ do $opts{gold} };

my %gold;

foreach my $s_ref (@gold_sent) {
  my $s_id = $s_ref->[0];
  foreach my $neo_ref ( @{ $s_ref }[1 .. $#{ $s_ref }] ) {
    my ($word, $pos) = @{ $neo_ref };
    $gold{$s_id}->{$word}->{$pos}++;
  }
}

my %tagged;
my %tagset;

open (my $fh, '<:encoding(utf-8)', $ARGV[0]) or die "Couldn't open $ARGV[0] for input: $!\n";

while (my $line = <$fh>) {

  next if ($line =~ m{ \A \s* \z }xms);
  chomp($line);

  my ($index, $token, $tag, $s_id, @rest) = split(/\t/, $line);
  if ($gold{"S_$s_id"}->{$token}) {
    $tagged{"S_$s_id"}->{$token}->{$tag}++;
  }
}

my %gold_talismane;

foreach my $s_id (map { $_->[0] }
		  sort { $a->[1] <=> $b->[1] } 
		  map { [$_, /S_(\d+)/ ] }  keys %gold) {

  print "$s_id\n";

  foreach my $word (sort { lc($a) cmp lc($b) } keys %{ $gold{$s_id} }) {
    foreach my $pos (sort keys %{ $gold{$s_id}->{$word} }) {
      push(@{ $gold_talismane{$s_id}->{gold} }, [ $word, $pos ]);
      print "GOLD: $word, $pos, $gold{$s_id}->{$word}->{$pos}\n";
    }
  }

  if ($tagged{$s_id}) {
    foreach my $word (sort { lc($a) cmp lc($b) } keys %{ $tagged{$s_id} }) {
      foreach my $pos (sort keys %{ $tagged{$s_id}->{$word} }) {
	push(@{ $gold_talismane{$s_id}->{tagger} }, [ $word, $pos ]);
	print "TALI: $word, $pos, $tagged{$s_id}->{$word}->{$pos}\n";
	$tagset{$pos}++;
      }
    }
  } else {
    print "No TALISMANE tagging for $s_id\n";
  }
}

if ($opts{csv_out}) {

  if (open(my $fh, '>:encoding(utf-8)', $opts{csv_out})) {

    print $fh join("\t", 's_id', 'g_word', 't_word', 'g_pos', 't_pos', 'correct?'), "\n";

    foreach my $s_id (map { $_->[0] }
		      sort { $a->[1] <=> $b->[1] } 
		      map { [$_, /S_(\d+)/ ] }  keys %gold_talismane) {

      foreach my $wp_ref_index (0 .. $#{ $gold_talismane{$s_id}->{gold} }) {

	my ($g_word, $g_pos) = @{ $gold_talismane{$s_id}->{gold}->[$wp_ref_index] };

	if ($gold_talismane{$s_id}->{tagger}) {
	  my ($t_word, $t_pos) = @{ $gold_talismane{$s_id}->{tagger}->[$wp_ref_index] };
	
	  my $correct = lc($g_pos) eq lc($t_pos) ? 1 : 0;
	  
	  unless ($correct) {
	    if ($g_pos eq 'verbe' and $t_pos =~ m{ \A V }xms) {
	      $correct = 1;
	    } elsif ($g_pos eq 'nom' and $t_pos =~ m{ \A N }xms) {
	      $correct = 1;
	    }
	  };

	  print $fh join("\t", $s_id, $g_word, $t_word, $g_pos, $t_pos, $correct), "\n";
	}
      }
    }
  } else {
    warn "Couldn't open $opts{csv_output} for output: $!\n";
  }
}

close $fh;

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

Copyright (C) 2014 by Ingrid Falk

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
