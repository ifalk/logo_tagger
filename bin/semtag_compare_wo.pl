#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# semtag_compare_wo.pl                   falk@lormoral
#                    16 Jul 2013

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

semtag_compare_wo.pl

=head1 USAGE

  perl semtag_compare.pl --gold=neo_index.pl neo_test_semtag.tagged

=head1 DESCRIPTION

 Compares the pos tagging produced by the semtag tagger with the part-of-speech tags given in the gold file (for neologisms recorded there).

=head1 REQUIRED ARGUMENTS

The pos tagging produced by Semtag. The format is the following :

 Son/DET appétit/NC institutionnel/ADJ est/V abracadabrantesquement/DET vorace/NC ./PONCT
 Ce/PRO que/PROREL tu/V fais/VPP là/ADV n'/ADV est/V pas/ADV accessibilisable/VPP en/P tant/CS que/_CS tel/ADJ ./PONCT
 C'/CLS est/V la/DET notion/NC de/_NC logement/_NC «/_NC accessibilisable/_NC -/_NC développée/_NC par/_NC TUTTIMOBI./_NC
 Accessibiliser/VINF l'/DET Internet/NC .../PONCT
oui/ADV ,/PONCT mais/CC pas/ADV à/P moitié/NC !/PONCT
 ...

One sentence per line.


=head1 OPTIONS


=over

=item gold

Index file used to retrieve the gold tags and compare them with the tags produced by Semtag. Format is a perl array with one entry - an array reference - for each gold sentence. The first element of each entry for a gold sentence is its sentence id, the next elements are an array reference [word, POS], for each neologism in the sentence.  

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

print STDERR scalar(@gold_sent), "\n";

my %gold;

foreach my $s_ref (@gold_sent) {
  my $s_id = $s_ref->[0];
  foreach my $neo_ref ( @{ $s_ref }[1 .. $#{ $s_ref }] ) {
    my ($word, $pos) = @{ $neo_ref };
    $gold{$s_id}->{$word}->{$pos}++;
  }
}

my %semtag;
my %tagset;

use List::MoreUtils qw(firstidx);

open (my $fh, '<:encoding(utf-8)', $ARGV[0]) or die "Couldn't open $ARGV[0] for input: $!\n";

while (my $line = <$fh>) {


  chomp($line);
  print STDERR "$. : $line", "\n";

  my $s_id = join('_', 'S', $.);
  my @gold_neos = @{ $gold_sent[$.-1] };

  # print STDERR "$s_id\n";
  my @tagged = split(/\s+/, $line);
  # print STDERR Dumper(\@tagged);
  foreach my $neo_ref_index (1 .. $#gold_neos) {
    my $neo_ref = $gold_neos[$neo_ref_index];

    # print STDERR join('/', @{ $neo_ref }), "\n";
    my $word = $neo_ref->[0];
    my @comp = split(/\s+/, $word);
    # print STDERR Dumper(\@comp);

    my @tagged_words;
    foreach my $w (@comp) {
      my $tagged_w_index = firstidx { $_ =~ m{ \b $w \/ }xms } @tagged;
      push(@tagged_words, $tagged[$tagged_w_index]);
      splice(@tagged, 0, $tagged_w_index+1);
      # print STDERR Dumper(\@tagged);
    }

    # print STDERR join(' ', @tagged_words), "\n";
    my @t_words;
    my @t_pos;
    foreach my $w_p (@tagged_words) {
      my ($w, $p) = split(/\//, $w_p);
      push(@t_words, $w);
      push(@t_pos, $p);
    }
    my $t_word = join(' ', @t_words);
    my $t_pos = join(' ', @t_pos);
    $semtag{$s_id}->{$t_word}->{$t_pos}++;
  }

}

close $fh;

my %gold_semtag;


foreach my $s_id (map { $_->[0] }
		  sort { $a->[1] <=> $b->[1] } 
		  map { [$_, /S_(\d+)/ ] }  keys %gold) {

  print "$s_id\n";
  foreach my $word (sort { lc($a) cmp lc($b) } keys %{ $gold{$s_id} }) {
    foreach my $pos (sort keys %{ $gold{$s_id}->{$word} }) {
      push(@{ $gold_semtag{$s_id}->{gold} }, [ $word, $pos ]);
      print "GOLD: $word, $pos, $gold{$s_id}->{$word}->{$pos}\n";
    }
  }

  if ($semtag{$s_id}) {
    foreach my $word (sort { lc($a) cmp lc($b) } keys %{ $semtag{$s_id} }) {
      foreach my $pos (sort keys %{ $semtag{$s_id}->{$word} }) {
	push(@{ $gold_semtag{$s_id}->{tagger} }, [ $word, $pos ]);
	print "SEMTAG: $word, $pos, $semtag{$s_id}->{$word}->{$pos}\n";
	$tagset{$pos}++;
      }
    }
  } else {
    print "No Semtag tagging for $s_id\n";
  }


}

if ($opts{csv_out}) {

  if (open(my $fh, '>:encoding(utf-8)', $opts{csv_out})) {

    print $fh join("\t", 's_id', 'g_word', 't_word', 'g_pos', 't_pos', 'correct?'), "\n";

    foreach my $s_id (map { $_->[0] }
		      sort { $a->[1] <=> $b->[1] } 
		      map { [$_, /S_(\d+)/ ] }  keys %gold_semtag) {

      foreach my $wp_ref_index (0 .. $#{ $gold_semtag{$s_id}->{gold} }) {

	my ($g_word, $g_pos) = @{ $gold_semtag{$s_id}->{gold}->[$wp_ref_index] };
	my ($t_word, $t_pos) = @{ $gold_semtag{$s_id}->{tagger}->[$wp_ref_index] };
	
	my $correct = lc($g_pos) eq lc($t_pos) ? 1 : 0;

	unless ($correct) {
	  if ($g_pos eq 'verbe' and $t_pos =~ m{ \A V }xms) {
	    $correct = 1;
	  } elsif ($g_pos eq 'nom' and $t_pos eq 'NC') {
	    $correct = 1;
	  }
	};

	print $fh join("\t", $s_id, $g_word, $t_word, $g_pos, $t_pos, $correct), "\n";
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

Copyright (C) 2013 by Ingrid Falk

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
