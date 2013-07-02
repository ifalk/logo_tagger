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

my %stanf;

my $sdom = XML::LibXML->load_xml(
  location => $ARGV[0],
  );

foreach my $s ($sdom->findnodes('//s')) {
  my $s_id = $s->getAttribute('id');
  my @wp = map { [ split(/_/, $_) ] } split(/\s+/, $s->textContent());
  print STDERR "$s_id\n";
  foreach my $g_neo (keys %{ $gold{$s_id} }) {
    my @words = split(/\s+/, $g_neo);
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