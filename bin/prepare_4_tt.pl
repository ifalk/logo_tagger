#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# prepare_4_tt.pl                   falk@lormoral
#                    09 Jul 2013

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

prepare_4_tt.pl

=head1 USAGE

   

=head1 DESCRIPTION

Stub documentation for prepare_4_tt.pl, 

=head1 REQUIRED ARGUMENTS

=head1 OPTIONS

=cut


my %opts = (
	    'an_option' => 'default value',
	   );

my @optkeys = (
	       'an_option:s',
	      );

unless (@ARGV) { pod2usage(2) };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

binmode(STDOUT, ':encoding(utf-8)');
binmode(STDERR, ':encoding(utf-8)');

use XML::LibXML;

my $dom = XML::LibXML->load_xml(
  location => $ARGV[0],
  );

my %s_ids;
foreach my $s ($dom->findnodes('//s')) {
  my $s_id = $s->getAttribute('id');
  print "<$s_id>\n";
  print join(' ', map {
    my $type = $_->nodeType();
    
    if ($type == 3) {
      $_->nodeValue();
    } elsif ($type == 1) {
      my $neo = $_->textContent();
      "<neo> $neo </neo>";
    }
	     } $s->childNodes()
    ), "\n";
  print "</$s_id>\n";
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
