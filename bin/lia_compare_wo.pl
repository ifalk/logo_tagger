#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# lia_compare_wo.pl                   falk@lormoral
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

lia_compare_wo.pl

=head1 USAGE

  perl lia_compare_wo.pl --gold=neo_index.pl neo_test_lia.tagged

=head1 DESCRIPTION

 Compares the pos tagging produced by the lia tagger with the part-of-speech tags given in the gold file (for neologisms recorded there).

=head1 REQUIRED ARGUMENTS

The pos tagging produced by lia. The format is the following :

 <s> ZTRM
 son DETMS
 appétit NMS
 institutionnel AMS
 est VE3S
 abracadabrantesquement ADV
 vorace AMS
 . YPFOR
 </s> ZTRM
 <s> ZTRM
 ce PDEMFS
 que COSUB
 tu VPPMS
 ...

One word per line, sentences are included in <<s>> <</s>> markup.

=head1 OPTIONS


=over

=item gold

Index file used to retrieve the gold tags and compare them with the tags produced by Lia. Format is a perl array with one entry - an array reference - for each gold sentence. The first element of each entry for a gold sentence is its sentence id, the next elements are an array reference [word, POS], for each neologism in the sentence.  

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
  );

my @optkeys = (
  'gold=s',
  'csv_out:s',
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

my %lia;

use List::MoreUtils qw(firstidx indexes natatime);

open (my $fh, '<:encoding(iso-8859-1)', $ARGV[0]) or die "Couldn't open $ARGV[0] for input: $!\n";


if ($opts{neo}) {

  my @sent;
  my $s_id;
  my $line = <$fh>;

 LINE: 
  while (defined($line) and $line =~ m{ \A <s> }xms) {
    $line = <$fh>;
    
    # print STDERR $line;
    
    if (my $new_s_id = ($line =~ m{ \A (S_\d+) \s }xms)[0]) {
      
      if ($s_id) {
	
	# print STDERR "Sid: ", $s_id, "\n";
	
	if (@sent) {

	  # print STDERR "Sent: ", join(' ', map { $_->[0] } @sent), "\n";
	  my @neo_indexes = indexes { $_->[0] eq 'NEO' } @sent;
	  my $it = natatime 2, @neo_indexes;
	  while (my @pair = $it->()) {
	    my $word = join(' ', map { $_->[0] } @sent[$pair[0]+1 .. $pair[1]-1]);
	    my $pos = join(' ', map { $_->[1] } @sent[$pair[0]+1 .. $pair[1]-1]);
	    $lia{$s_id}->{$word}->{$pos}++;
	  }
	} else {
	  print STDERR "No sentence for $s_id\n";
	}
      }
      $s_id = "$new_s_id";
	
      # print STDERR $new_s_id, "\n";
      
      @sent = ();
      
      $line = <$fh>; # </s>
      # print STDERR "$line (expected </s>)\n";
      $line = <$fh>; # <s>
      # print STDERR "$line (expected <s>)\n";
      
      $line = <$fh>;
      while (defined($line) and $line !~ m{ \A </s> }xms) {
	# print STDERR $line;
	chomp($line);
	my ($word, $pos) = split(/\s+/, $line);
	push(@sent, [$word, $pos]);
	$line = <$fh>;
      }
      
      $line = <$fh>; # <s>
      # print STDERR "$line (expected <s>)", "\n";
      next LINE;
    }
  }



  if ($s_id) {
    
    # print STDERR "Sid: $s_id\n";
    
    if (@sent) {
      
      # print STDERR "Sent: ", join(' ', map { $_->[0] } @sent), "\n";
      
      my @neo_indexes = indexes { $_->[0] eq 'NEO' } @sent;
      my $it = natatime 2, @neo_indexes;
      while (my @pair = $it->()) {
	my $word = join(' ', map { $_->[0] } @sent[$pair[0]+1 .. $pair[1]-1]);
	my $pos = join(' ', map { $_->[1] } @sent[$pair[0]+1 .. $pair[1]-1]);
	$lia{$s_id}->{$word}->{$pos}++;
      }
    } else {
      print STDERR "No sentence for $s_id\n";
    }
  }

} else {
  
  my $s_count = 1;
  my @tagged;

  while (my $line = <$fh>) {

    if ($line =~ m{ \A </s> }xms) {

      my $s_id = join('_', 'S', $s_count);

      # print STDERR $s_id, "\n";

      my @gold_neos = @{ $gold_sent[$s_count-1] };
      foreach my $neo_ref_index (1 .. $#gold_neos) {
	my $neo_ref = $gold_neos[$neo_ref_index];

	# print STDERR Dumper($neo_ref);

	my $g_word = $neo_ref->[0];
	my @comp = split(/\s+/, $g_word);
	
	my @t_words;
	my @t_pos;
	foreach my $w (@comp) {
	  
	  my $tagged_w_index = firstidx { $_ =~ m{ \b $w \b }xmsi } map { $_->[0] } @tagged;

	  push(@t_words, $tagged[$tagged_w_index]->[0]);
	  push(@t_pos, $tagged[$tagged_w_index]->[1]);
	  splice(@tagged, 0, $tagged_w_index+1);
	}

	my $t_word = join(' ', @t_words);
	my $t_pos = join(' ', @t_pos);

	# print STDERR $t_word, "\n";
	# print STDERR $t_pos, "\n";

	$lia{$s_id}->{$t_word}->{$t_pos}++;
      }
    
      @tagged = ();
      $s_count++;
      
    } elsif ($line =~ m{ \A <s> }xms) {
      next;
    } else {
      chomp($line);
      my ($word, $pos) = split(/\s+/, $line);
      push(@tagged, [ $word, $pos ]);
    }
  }
}

close $fh;

my %gold_lia;


foreach my $s_id (map { $_->[0] }
		  sort { $a->[1] <=> $b->[1] } 
		  map { [$_, /S_(\d+)/ ] }  keys %gold) {

  print "$s_id\n";
  foreach my $word (sort { lc($a) cmp lc($b) } keys %{ $gold{$s_id} }) {
    foreach my $pos (sort keys %{ $gold{$s_id}->{$word} }) {
      push(@{ $gold_lia{$s_id}->{gold} }, [ $word, $pos ]);
      print "GOLD: $word, $pos, $gold{$s_id}->{$word}->{$pos}\n";
    }
  }

  if ($lia{$s_id}) {
    foreach my $word (sort { lc($a) cmp lc($b) } keys %{ $lia{$s_id} }) {
      foreach my $pos (sort keys %{ $lia{$s_id}->{$word} }) {
	push(@{ $gold_lia{$s_id}->{tagger} }, [ $word, $pos ]);
	print "LIA: $word, $pos, $lia{$s_id}->{$word}->{$pos}\n";
      }
    }
  } else {
    print "No Lia tagging for $s_id\n";
  }


}

if ($opts{csv_out}) {

  if (open(my $fh, '>:encoding(utf-8)', $opts{csv_out})) {

    print $fh join("\t", 's_id', 'g_word', 't_word', 'g_pos', 't_pos', 'correct?'), "\n";

    foreach my $s_id (map { $_->[0] }
		      sort { $a->[1] <=> $b->[1] } 
		      map { [$_, /S_(\d+)/ ] }  keys %gold_lia) {

      foreach my $wp_ref_index (0 .. $#{ $gold_lia{$s_id}->{gold} }) {

	my ($g_word, $g_pos) = @{ $gold_lia{$s_id}->{gold}->[$wp_ref_index] };
	my ($t_word, $t_pos) = @{ $gold_lia{$s_id}->{tagger}->[$wp_ref_index] };
	
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
