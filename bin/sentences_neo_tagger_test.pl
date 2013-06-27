#!/usr/bin/perl
# -*- mode: perl; buffer-file-coding-system: utf-8 -*-
# sentences_neo_tagger_test.pl                   falk@lormoral
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

sentences_neo_tagger_test.pl

=head1 USAGE

   

=head1 DESCRIPTION

Stub documentation for sentences_neo_tagger_test.pl, 

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

# binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

use XML::LibXML;

my $parser = XML::LibXML->new();

my $dom = XML::LibXML->load_xml(
  location => $ARGV[0],
  );

# map { print STDERR $_->textContent() } $dom->findnodes('//texte');

my $s_count = 0;
my @texts = $dom->findnodes('//texte');

foreach my $t (@texts) {

  my $str = $t->toString();

  next if ($str =~ m{ \A \s* \z }xms);
  my @sent = split(/\n/, $str);

  my $last = pop(@sent);

  my $xml_string = join('', 
			$sent[0], 
			map { 
			  my $s = $_; 
			  $s =~ s{ \A \s+ }{}xms;
			  $s =~ s{ \s+ \z }{}xms;
			  $s =~ s{ \s+ }{ }xmsg;
			  $s_count = $s_count+1;
			  join('', "\n<s id='S_$s_count'>", $s, '</s>', "\n"); 			
			}
			grep { $_ !~ m{ \A \s* \z }xms } 
			@sent[1..$#sent]
    );
  
  $xml_string = join('', $xml_string, $last);
  
  my $frag = $parser->parse_balanced_chunk($xml_string);
  
  $t->replaceNode($frag);
}

print $dom->toString(1);







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
