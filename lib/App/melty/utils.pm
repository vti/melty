package App::melty::utils;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(check_output_and_execute execute);

sub check_output_and_execute {
    my ($output, $cmd) = @_;

    my $code;
    if ($output) {
        $cmd .= " -consumer avformat:$output vcodec=libx264 preset=ultrafast";

        if (-f $output) {
            $code = sub {
                print "File '$output' exists. Overwrite ? (y/n): ";
                chomp(my $answer = <STDIN>);
                exit(0) unless lc($answer) eq 'y';
            };
        }
    }

    execute($cmd, $code);
}

sub execute {
    my ($cmd, $code) = @_;

    print "$cmd\n";

    $code->() if $code;

    system($cmd);

    die "FAIL\n" if $?;
}

1;
