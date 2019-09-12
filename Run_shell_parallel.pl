#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;
use threads;
use Thread::Queue;

## run shell script in paralle;
## Shuqing Xu
## 6/27/2013
our ($opt_n, $opt_s);
getopts("n:s:");
my  $version="Version 1.0";
my $usage="
$version

Please test your shell script before using this function!

perl $0 -n number of thread to use -s shell script file

";

unless ($opt_n) {
	print $usage;
	exit;
}
unless ($opt_s) {
	print $usage;
	exit;
}

my @shell;
open (I,$opt_s);
while (<I>) {
	if (/\S+/) {
		$_=~tr/\n//d;
		push (@shell,$_);
	}
}

&RUNSHELL($opt_n,\@shell);

sub RUNSHELL{
    my $num_threads = shift;
	my $shell_ref=shift;
    my $queue = new Thread::Queue;

## save all the shell command in the queue;
    while ($_ = shift @{$shell_ref}) {
            $queue->enqueue($_);
    }


# run command;
for (0..$num_threads-1) {
		@{$shell_ref}[$_] = new threads(\&worker);
    }

sub worker() {
	while (my $shell = $queue->dequeue) {
		my @args=("bash","-c",$shell);
		print join " ", @args,"\n";
			system ( @args );
	}
}

for (0..$num_threads-1) { $queue->enqueue(undef); }
for (0..$num_threads-1) { @{$shell_ref}[$_]->join; } # finish up;
}


