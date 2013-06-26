#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# make_tagger_test_corpus.pl                   falk@lormoral
#                    20 Jun 2013

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

make_tagger_test_corpus.pl

=head1 USAGE

  perl make_tagger_test_corpus.pl wiki neologisms corpus

=head1 DESCRIPTION

Extracts neologisms occurences from the xml wiki neologisms corpus. Since the resulting xml file is needed to test tagger performance on unknown words we only keep relevant information.

=over

=item the neologism:

<<terme>>abracadabrantesquement<</terme>>

=item information about part of speach:

<<type origine="abracadabrantesque" nature="adv">>Xment<</type>>

=item the examples containing this word

 <<sources>>
   <<texte url="http://www.bruxelles-francophone.be/topic2035.html" type="forum" date="2009">>

 LA BELGIQUE FRANCOPHONE DEPECEE MORCEAU PAR MORCEAU
 au fil des réformes institutionnelles … Revisitons l’étal de 1962 à 2005…

 ....

The text element also gets an id 

=back

=head1 REQUIRED ARGUMENTS

The xml file with the neologisms.

=head1 OPTIONS

=cut


my %opts = (
	    'an_option' => 'default value',
	   );

my @optkeys = (
	       'an_option:s',
	      );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

unless (@ARGV) { pod2usage(2); };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

use XML::LibXML;

my $dom = XML::LibXML->load_xml(
  location => $ARGV[0],
  );

my $tdom = XML::LibXML->createDocument('1.0', 'UTF-8');
my $tc = $tdom->createElement('corpus');
$tdom->setDocumentElement($tc);

my %types;

my @fiches = $dom->findnodes('//fiche');
print STDERR "Number of neo entries: ", scalar(@fiches), "\n";

foreach my $fiche (@fiches) {
  my $f_id = $fiche->getAttribute('id');
  print STDERR $f_id, "\n";

  
  my $tf = $tdom->createElement('entry');
  $tf->setAttribute('id', $f_id);
  
  my @terms = $fiche->findnodes('terme');
  
  unless( scalar(@terms) == 1 ) {
    warn "More than one term for fiche $f_id\n";
  }
  
  my $term = $terms[0]->textContent();
  my $word = $tdom->createElement('word');
  $word->addChild($tdom->createTextNode($term));
  
  my @types = $fiche->findnodes('type');
  unless( scalar(@types) == 1 ) {
    warn "More than one type for fiche $f_id\n";
  }
  if ($types[0]->hasAttribute('nature')) {
    my $pos = $types[0]->getAttribute('nature');
    $types{$pos}++;
    $word->setAttribute('pos', $pos);
  } else {
    print STDERR "No POS for fiche $f_id ($term)\n";
  }
  
  $tf->addChild($word);

  my $ex = $tdom->createElement('examples');
  
  my @examples = $fiche->findnodes('.//texte');

  foreach my $iex (0 .. $#examples) {
    my $ex_id = join('-', $f_id, $iex+1);
    my $ex_text = $examples[$iex]->textContent();

    my $ex_el = $tdom->adoptNode($examples[$iex]);
    $ex_el->setAttribute('id', $ex_id);
    
    $ex->addChild($ex_el);

  }

  $tf->addChild($ex);
  $tc->addChild($tf);

}

print STDERR Dumper(\%types);

$tdom->toFH(\*STDOUT, 1);

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
