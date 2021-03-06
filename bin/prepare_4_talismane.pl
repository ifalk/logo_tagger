#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# prepare_4_talismane.pl                   falk@lormoral
#                    21 Mar 2014

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

prepare_4_talismane.pl

=head1 USAGE

   

=head1 DESCRIPTION

Stub documentation for prepare_4_talismane.pl, 

=head1 REQUIRED ARGUMENTS

=head1 OPTIONS

=cut


my %opts = (
  'neo' => 1,
  );

my @optkeys = (
  'neo!',
  );


unless (GetOptions (\%opts, @optkeys)) { pod2usage(2); };
unless (@ARGV) { pod2usage(2) };

print STDERR "Options:\n";
print STDERR Dumper(\%opts);

1;


binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use XML::LibXML;

my $dom = XML::LibXML->load_xml(
  location => $ARGV[0],
  );

my @sent_index;

foreach my $entry ($dom->findnodes('//entry')) {

  my $pos = ($entry->findnodes('word'))[0]->getAttribute('pos');

  foreach my $s ($entry->findnodes('.//s')) {

    my $s_id = $s->getAttribute('id');

    my $text = $s->textContent();
    print $text, "\n";

    my @neos;
    foreach my $neo (map { $_->textContent() } $s->findnodes('neologisme')) {
      push(@neos, [ $neo, $pos ]); 
    }
    push (@sent_index, [ $s_id,  @neos ]);
  }
}

unless ($opts{neo}) {

  if (open (my $fh, '>:encoding(utf-8)', 'neo_index.pl')) {
    print $fh Dumper(\@sent_index);
  } else {
    print STDERR "Couldn't open $opts{neo} for output: $!\n";
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

Copyright (C) 2014 by Ingrid Falk

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
