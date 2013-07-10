#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# semtag_compare.pl                   falk@lormoral
#                    10 Jul 2013

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

semtag_compare.pl

=head1 USAGE

  perl semtag_compare.pl --gold=${NEO_TAGGER_TEST_SENT} neo_test_semtag.tagged

=head1 DESCRIPTION

 Compares the pos tagging produced by the semtag tagger with the part-of-speech tags given in the gold file (for neologisms recorded there).

=head1 REQUIRED ARGUMENTS

The pos tagging produced by Semtag. The format is the following :

 1/ADJ
 Son/DET appétit/NC institutionnel/ADJ est/V <neo>/DET abracadabrantesquement/NC </neo>/ADJ vorace/NC ./PONCT
 2/DET
 Ce/PRO que/PROREL tu/V fais/VPP là/ADV n'/ADV est/V pas/ADV <neo>/_ADV accessibilisable/_ADV </neo>/_ADV en/_ADV tant/CS que/_CS tel/ADJ ./PONCT
 ....

=head1 OPTIONS

=over

=item gold XML file containing gold pos assignments for neologisms.

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

my %semtag;

open (my $fh, '<:encoding(utf-8)', $ARGV[0]) or die "Couldn't open $ARGV[0] for input: $!\n";

my $s_id;
my @comp;
while (my $line = <$fh>) {
  chomp($line);
  if (my ($s_nbr) = ($line =~ m{ \A (\d+) \/[A-Z_]+ \z }xms)) {

    # print STDERR "$s_nbr\n";

    if ($s_id) {

      # print STDERR "$s_id\n";

      if (@comp) {
	my $seq = join(' ', @comp);
	my (@word_pos) = ($seq =~ m{ <neo>\/[A-Z_]+ \s+ (.*?) \s+ </neo> }xmsgi);
	# print STDERR Dumper(\@word_pos);
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
	    $semtag{$s_id}->{$word}->{$pos}++;
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
    my (@word_pos) = ($seq =~ m{ <neo>\/[A-Z]+ \s+ (.*?) \s+ <\/neo> }xmsgi);
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
	$semtag{$s_id}->{$word}->{$pos}++;
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

# print STDERR Dumper(\%semtag);

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
      }
    }
  } else {
    print "No Semtag tagging for $s_id\n";
  }


}

# print STDERR Dumper(\%gold_semtag);

if ($opts{csv_out}) {

  if (open(my $fh, '>:encoding(utf-8)', $opts{csv_out})) {

    print $fh join("\t", 's_id', 'g_word', 't_word', 'g_pos', 't_pos', 'correct?'), "\n";

    foreach my $s_id (map { $_->[0] }
		      sort { $a->[1] <=> $b->[1] } 
		      map { [$_, /S_(\d+)/ ] }  keys %gold_semtag) {

      # print STDERR $s_id, "\n";
      foreach my $wp_ref_index (0 .. $#{ $gold_semtag{$s_id}->{gold} }) {

	my ($g_word, $g_pos) = @{ $gold_semtag{$s_id}->{gold}->[$wp_ref_index] };
	my ($t_word, $t_pos) = @{ $gold_semtag{$s_id}->{tagger}->[$wp_ref_index] };
	
	my $correct = lc($g_pos) eq lc($t_pos) ? 1 : 0;

	unless ($correct) {
	  if ($g_pos eq 'verbe' and $t_pos =~ m{ \A V }xms) {
	    $correct = 1;
	  } elsif ($g_pos eq 'nom' and $t_pos =~ m{ \A _?NC }xms) {
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
