#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# analyse_neo_tagger_test.pl                   falk@lormoral
#                    27 Jun 2013

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

analyse_neo_tagger_test.pl

=head1 USAGE

   

=head1 DESCRIPTION

Stub documentation for analyse_neo_tagger_test.pl, 

=head1 REQUIRED ARGUMENTS

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

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');


my $dom = XML::LibXML->load_xml(
  location => $ARGV[0],
  );

my @entries = $dom->findnodes('//entry');

my @neos; # neo, pos, #texts, #occ

my %mwes;

print join("\t", qw(neo pos texts occ)), "\n";

foreach my $e (@entries) {
  my $neo_el = ($e->findnodes('word'))[0];
  my $neo = $neo_el->textContent();
  my @comp = split(/\s+/, $neo);
  if (scalar(@comp) > 1) {
    $mwes{$neo}++;
  }

  my $pos = 'NA';
  if ($neo_el->hasAttribute('pos')) {
    $pos = $neo_el->getAttribute('pos');
  };

  my @texts = $e->findnodes('.//texte');
  my $nbr_texts = scalar(@texts);
  my @occurences = $e->findnodes('.//neologisme');
  my $nbr_occ = scalar(@occurences);

  print join("\t", $neo, $pos, $nbr_texts, $nbr_occ), "\n";
}

print STDERR Dumper(\%mwes);

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
