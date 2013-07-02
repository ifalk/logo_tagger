#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# prepare_4_lg.pl                   falk@lormoral
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

prepare_4_lg.pl

=head1 USAGE

   

=head1 DESCRIPTION

Stub documentation for prepare_4_lg.pl, 

=head1 REQUIRED ARGUMENTS

=head1 OPTIONS

=cut


my %opts = (
	    'list_known_words' => '',
	   );

my @optkeys = (
	       'list_known_words:s',
	      );

unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };

unless (@ARGV) { pod2usage(2) };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use XML::LibXML;

my $dom = XML::LibXML->load_xml(
  location => $ARGV[0],
  );

my %s_ids;
foreach my $s ($dom->findnodes('//s')) {
  my $s_id = $s->getAttribute('id');
  $s_ids{$s_id}++;
  $s_id =~ s{ S_ }{}xms;
  print "$s_id\n";
  
  print join(' ', map {
    my $type = $_->nodeType();
    
    if ($type == 3) {
      $_->nodeValue();
    } elsif ($type == 1) {
      my $neo = $_->textContent();
      "NEO $neo NEO";
    }
	     } $s->childNodes()
    ), "\n";
}

print STDERR Dumper(\%s_ids);

if ($opts{list_known_words}) {
  if (open (my $fh, '>:encoding(utf-8)', $opts{list_known_words})) {
    foreach my $s_id (map { $_->[0] }
		      sort { $a->[1] <=> $b->[1] } 
		      map { [$_, /S_(\d+)/ ] } keys %s_ids) {
      print $fh join("\t", $s_id, $s_id, 'SENT'), "\n";
    }
  } else {
    print STDERR "Couldn't open $opts{list_known_words} for output: $!\n";
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
