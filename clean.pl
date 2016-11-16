#!/usr/bin/env perl

use warnings;
use strict;
use Path::Tiny qw(path);
use Term::ANSIColor;

# Author: Mark O Grady
# This script simply formats your templates to remove extra lines and whitespace at the end of lines.
my $file = defined $ARGV[0] ? $ARGV[0] : "";
check_input($file);
sub check_input {
	my $filename = shift;
	if ($filename eq "") {
		msg_out(0);
	} else {
        clean_template($filename);
	}
}
sub clean_template {
    my $filename = shift;
    my $fparse = shift;
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
    	 	print "Unnecessary force_parsing:" . color('bold red') . " @defaults\n";
		}
    }
}

sub check_parsing {
    my $filename = shift;
    my @defaults;
    my $line;
    open(my $fh, "<", $filename) or die "Cannot open file: $!";
    while(my $line = <$fh>) {
	    location_state($line);
    }
   close $fh;
}

sub location_state {
    my $handle = shift;
    my $state = 0;
    my $tmp = $handle;
    $state = check_one($tmp);
    check_two($handle, $state);
}

sub check_one {
    my $handle = shift;
    my $no_state;
        if($handle =~ m/force_parse: /) { 
            my $no_state =  $handle =~ /(%location_state%)/g ? 0 : 1;
            return $no_state;
        } 
        return 1;
}

sub check_two {
    my $tmp = shift;
    my $no_state = shift;
    if($tmp =~ m/location_text_region/g) {
    print "in inner region $no_state\n\n";
        if($no_state) {
            print color('white') . "You should be force parsing %location_state%\n"; 
       }
    }
}

sub msg_out {
	my ($out_val, $options) = @_;
	my %msg = ( 
		0 => color('bold red') . "You must specify a file to clean." . color('cyan')  . " EXAMPLE: ./clean filename.template",
		1 => color('bold red') ."Your file is not a .template file",
		2 => color('bold green') ."Your file has been cleaned :)",
        3 => color('bold red') . "You must specify a file to use with the option "# . $options . color('cyan')  . " EXAMPLE: ./clean " . $options . " filename.template"
	);
	print $msg{$out_val} . "\n";
}
