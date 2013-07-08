#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# lia_compare.pl                   falk@lormoral
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

lia_compare.pl

=head1 USAGE

  perl lia_compare.pl --gold=${NEO_TAGGER_TEST_SENT} neo_test_lia.tagged
   

=head1 DESCRIPTION

 Compares the pos tagging produced by the lia tagger with the part-of-speech tags given in the gold file (for neologisms recorded there).

The pos tagging produced by Lia. The format is the following :

 <s> ZTRM                              <<- start sentence marker
 S_1 MOTINC                            <<- sentence id
 </s> ZTRM                             <<- end of sentence marker
 <s> ZTRM
 son DETMS
 appétit NMS
 institutionnel AMS
 est VE3S
 NEO MOTINC                            <<- neologism start marker
 abracadabrantesquement ADV 
 NEO MOTINC                            <<- neologism end marker
 vorace AMS
 . YPFOR
 </s> ZTRM


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

my %lia;

open (my $fh, '<:encoding(iso-8859-1)', $ARGV[0]) or die "Couldn't open $ARGV[0] for input: $!\n";

my @sent;
my $s_id;
my $line = <$fh>;

use List::MoreUtils qw(indexes natatime);

LINE:
  while (defined($line)) {

    # print STDERR $line;

    if ($line =~ m{ \A <s> }xms) {
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
	# print STDERR "FH: $line";
	$line = <$fh>; # <s>
	# print STDERR "FH: $line";
	
	$line = <$fh>;
	while (defined($line) and $line !~ m{ \A </s> }xms) {
	  # print STDERR $line;
	  chomp($line);
	  my ($word, $pos) = split(/\s+/, $line);
	  push(@sent, [$word, $pos]);
	  $line = <$fh>;
	}
      }
    } else {
      print STDERR "Unexpected line $line\n";
    }
    $line = <$fh>;
}

if ($s_id) {
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

  if ($lia{$s_id}) {
    foreach my $word (sort keys %{ $lia{$s_id} }) {
      foreach my $pos (sort keys %{ $lia{$s_id}->{$word} }) {
	print "LIA: $word, $pos, $lia{$s_id}->{$word}->{$pos}\n";
      }
    }
  } else {
    print "No Lia tagging for $s_id\n";
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
