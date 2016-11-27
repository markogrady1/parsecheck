#!/usr/bin/env perl

use warnings;
use strict;
use Path::Tiny qw(path);
use Term::ANSIColor;

# Author: Mark O Grady
# Formats templates to remove extra whitespace.
# checks for default tokens.

my $file = defined $ARGV[0] ? $ARGV[0] : "";

unless ($file eq '') {
    print $file . " will be cleaned. Is this correct?\n";
    my $input = <STDIN>;
    clean_template($file) if $input =~ m/^yes$|^y$/i;
    exit;
} else {
	msg_out(0);
}

sub clean_template {
    my $filename = shift;
	my ($line, $content);
    if($filename =~ m/\S.+\.template$/) {
		my $file = path($filename);
		my $data = $file->slurp_utf8;
		while ($line = <>) {
           	tokens($line);
			$line =~ s/(\s+)$/\n/g;
			$content .= $line;
		}
		$content =~ s/^(?:[\t ]*(?:\r?\n|\r)){2,}/\n/gm;
		$file->spew_utf8($content);
    	msg_out(2);
    } else {
		msg_out(1);
    }
}

sub tokens {
    my $handle = shift;
    if($handle =~ m/force_parse: /) {
    	my @defaults =  $handle =~ /(%industry%|%jobtitle%|%jobtype%|%description%|%salary%|%salary2%|%jobref%|%aplitrakid%|%rwcontactemail%|%salary_banding%|%applyonline%|%allow_applyonline%|%aplitrakurl%|%job_id%|%job_url%|%location_id%|%aplitrakurl_encoded%|%account_type%|%locale%|%brand_id%|%strapline%|%eaa_tag%)/g;
		if(@defaults) {
    	 	print "Unnecessary force parsing:" . color('bold red') . " @defaults\n";
		}
        unless($handle =~ /(%location_state%)/g) {
            msg_out(4);
        }
    }
}

sub msg_out {
	my $out_val = shift;
	my %msg = (
		0 => color('bold red') . "You must specify a file to clean." . color('cyan')  . " EXAMPLE: ./clean.pl filename.template",
		1 => color('bold red') ."Your file is not a .template file",
		2 => color('bold green') ."Your file has been cleaned :)",
        3 => color('bold red') . "You must specify a file to use with the option ",
        4 => color('reset') . "not force parsed:" . color('bold yellow') . "%location_state%",
	);
	print $msg{$out_val} . "\n";
}


