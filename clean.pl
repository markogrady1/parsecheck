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
        if(not defined $ARGV[1]) { 
            clean_template($filename, 1);
        } else {
            for my $opts (@ARGV) {
                if ($opts =~ m/--fp|--fparse/) {
                    if (defined $ARGV[1]) {
                        check_parsing($ARGV[1]);
                    } else {
                        msg_out(3, '--fp | --fparse');
                    }
                } elsif($opts =~ m/--c|--clean/) {
                    if (defined $ARGV[1]) {
                        clean_template($ARGV[1], 0);
                    } else {
                        msg_out(3, '--c | --clean');
                    }
                } 
            }
        }
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
            if($fparse) { 
            #location_state($line); 
            tokens($line);
            }
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
     print "Unnecessary force_parsing:" . color('bold red') . " @defaults\n";
    }
}

sub check_parsing {
    my $filename = shift;
    my @defaults;
    if($filename =~ m/.+\.template$/) {
        my $line;
        open(my $fh, "<", $filename) or die "Cannot open file: $!";
        while(my $line = <$fh>) {
            location_state($line);
#            if($line =~ m/force_parse: /) { 
            tokens($line);
               # @defaults =  $line =~ /(%industry%|%jobtitle%|%jobtype%|%description%|%salary%|%salary2%|%jobref%|%aplitrakid%|%rwcontactemail%|%salary_banding%|%applyonline%|%allow_applyonline%|%aplitrakurl%|%job_id%|%job_url%|%location_id%|%aplitrakurl_encoded%|%account_type%|%locale%|%brand_id%|%strapline%|%eaa_tag%)/g;
                #print "You are force_parsing @defaults";
            }
#        }
        close $fh;
     } else {
		msg_out(1);
    }

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
