#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Std;
use File::Spec;
use File::Basename;
use Time::Piece;
use POSIX;

=pod

Simple archiving tool covering 2 cases:

- Move content that older than given date to archive directory.
- Keep only given number of files in current directory, by moving the oldest files to archive directory

Usage:

perl archive.pl -s /source/dir -d /destination/dir [-l <leave-number-of-last-files> ] [-o <YYYY-MM-DD hh:mm:ss> ] [ -k "keep_file1,keep_file2" ]

-s - source directory from where unnecessary files are moved
-d - destination archive directory where unnecessary files are stored

-l - keeps number argument, that specifies the number of files being left in current directory. Older files are moved, newer kept.

-d - keeps date string argument like '2022-01-01 10:00:00'. All files changed before this date are moved to archive directory.

-k - comma-separated list of filenames, that must be left in source directory untouched, reagrdless on how old it is. You can use backslash to escape commas if it presented in filename.

=cut


our %opts;
getopts('l:o:s:d:k:', \%opts);


if (! -d $opts{s}) {
    die "Source directory $opts{s} does not exist";
}
if (! -d $opts{d}) {
    die "Archive directory $opts{s} does not exist";
}

my @files = glob( File::Spec->catfile($opts{s}, "*") ) ;
my $total = scalar(@files);

my %keep_files = map { $_ => 1; } split(/(?<!\\),/, $opts{k} // "");


if ($opts{o}) {
    my $timezone = strftime('%z', localtime());
    my $relative_unix_time = Time::Piece->strptime($opts{o} . " $timezone", '%Y-%m-%d %H:%M:%S %z')->epoch();

    my $i = 0;
    foreach my $file (@files) {
        $i++;

        my $file_unix_time = (stat($file))[9];

        print "$i of $total - $file";

        if ($keep_files{$file}) {
            print " skipped" . "\n";
            next;
        }

        if ($file_unix_time <= $relative_unix_time) {
            my $exec_string = sprintf(
                "mv \"%s\" \"%s\"",
                $file,
                File::Spec->catfile(
                    $opts{d},
                    File::Basename::basename($file)
                )
            );

            system($exec_string);

            print " moved" . "\n";
        } else {
            print " skipped" . "\n";
        }
    }
} elsif ($opts{l}) {
    @files = sort {
        my $atime = (stat($a))[9];
        my $btime = (stat($b))[9];

        $atime <=> $btime;
    } @files;

    for (my $i = 0; $i < $total; $i++) {

        print "$i of $total - $files[$i]";

        if ($keep_files{$files[$i]}) {
            print " skipped" . "\n";
            next;
        }

        if (($total - $i) > $opts{l}) {
            my $exec_string = sprintf(
                "mv \"%s\" \"%s\"",
                $files[$i],
                File::Spec->catfile(
                    $opts{d},
                    File::Basename::basename($files[$i])
                )
            );

            system($exec_string);
            print " moved" . "\n";
        } else {
            print " skipped" . "\n";
        }
    }
}
else {
    die "You must specify -o or -l option";
}
