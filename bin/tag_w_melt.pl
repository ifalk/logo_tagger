#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# tag_w_melt.pl                   falk@lormoral
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

tag_w_melt.pl

=head1 USAGE

   perl tag_w_melt.pl   --tagger_output tagger output file
                        xml tagger input file 
                      

=head1 DESCRIPTION

Runs the MElt tagger on the phrases provided in the argument file.

=head1 REQUIRED ARGUMENTS

An XML file containing annotated examples with neologisms.

The expected format is as follows :

 <lt>?xml version="1.0" encoding="UTF-8"?<gt>
 <lt>corpus<gt>
  <lt>entry id="L00001"<gt>
    <lt>word pos="adv"<gt>abracadabrantesquement<lt>/word<gt>
    <lt>examples<gt>
      <lt>texte url="http://www.bruxelles-francophone.be/topic2035.html" type="forum" date="2009" id="L00001-1"<gt>
 <lt>s id="S_1"<gt>Son appétit institutionnel est <lt>neologisme<gt>abracadabrantesquement<lt>/neologisme<gt> vorace.<lt>/s<gt>
      <lt>/texte<gt>
    <lt>/examples<gt>
  <lt>/entry<gt>
  <lt>entry id="L00002"<gt>
    <lt>word pos="adj"<gt>accessibilisable<lt>/word<gt>
    <lt>examples<gt>
      <lt>texte url="http://forum.alsacreations.com/topic-6-46672-1-Accessibilite-des-documents-a-telecharger.html" date="2010" type="forum" id="L00002-1"<gt>
 <lt>s id="S_2"<gt>Ce que tu fais là n'est pas <lt>neologisme<gt>accessibilisable<lt>/neologisme<gt> en tant que tel.<lt>/s<gt>
      <lt>/texte<gt>
    ....


=head1 OPTIONS

=over

=item tagger_output

File name where the tagger output should be written to.

The expected output file format is as follows :

 1/DET
 Son/DET apptit/NC institutionnel/ADJ est/V abracadabrantesquement/ADV vorace/ADJ ./PONCT
 2/DET
 Ce/PRO que/PROREL tu/VPP fais/V l/ADV n'/ADV est/V pas/ADV accessibilisable/VPP en/P tant/ADV que/CS tel_./ADV tel_./PONCT
 ....

Every tagged sentence is preceded by the sentence number in the original file. Ie. the tagged sentence on line 2 has the id I<1> in the original xml file.


=back

=cut


my %opts = (
	    'tagger_output' => '',
	   );

my @optkeys = (
	       'tagger_output=s',
	      );


unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

unless (@ARGV) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

binmode(STDERR, ':utf8');

use XML::LibXML;

my $dom = XML::LibXML->load_xml(
  location => $ARGV[0],
  );

my @entries = $dom->findnodes('//entry');

open(my $pipe, "| MElt -t >> $opts{tagger_output}")
  || die "can't fork: $!";

foreach my $entry (@entries[0..10]) {

  foreach my $s ($entry->findnodes('.//s')) {
    my $s_id = $s->getAttribute('id');
    $s_id =~ s{ S_ }{}xms;
    print $pipe "$s_id\n", $s->textContent();
  }
}

close $pipe  || die "Error closing pipe: $! $?";

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
