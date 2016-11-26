#!/usr/bin/env perl

use warnings;
use strict;
use Path::Tiny qw(path);
use Term::ANSIColor;

my $file = defined $ARGV[0] ? $ARGV[0] : "";
my $state = 0;
file_check($file);

sub file_check {
    my $filename = shift;
    my $line;
    unless ($filename eq '') { 
        if($filename =~ m/\S.+\.template$/) {
		    my $file = path($filename);
		    my $data = $file->slurp_utf8;
            while($line = <>) {
           	   tokens($line);
            }
        } else {
            msg_out(1);
        }
    } else {
        msg_out(0);	
    }
}

sub tokens {
    my $handle = shift;
    if($handle =~ m/force_parse: /) { 
    	my @defaults =  $handle =~ /(%industry%|%jobtitle%|%jobtype%|%description%|%salary%|%salary2%|%jobref%|%aplitrakid%|%rwcontactemail%|%salary_banding%|%applyonline%|%allow_applyonline%|%aplitrakurl%|%job_id%|%job_url%|%location_id%|%aplitrakurl_encoded%|%account_type%|%locale%|%brand_id%|%strapline%|%eaa_tag%)/g;
		if(@defaults) {
    	 	print "Unnecessary force parsing:" . color('bold red') . " @defaults\n";
		}
        $state = 1 unless $handle =~ /%location_state%/;
    }
    if($handle =~ m/location_text_region/g && $state) {
        msg_out(2);
    }
}

sub msg_out {
	my $out_val = shift;
	my %msg = ( 
		0 => color('bold red') . "You must specify a file to clean." . color('cyan')  . " EXAMPLE: ./clean.pl filename.template",
		1 => color('bold red') ."Your file is not a .template file",
        2 => color('reset') . "Missing from force parse:" . color('bold yellow') . "%location_state%",
	);
	print $msg{$out_val} . "\n";
}

