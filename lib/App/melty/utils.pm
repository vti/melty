package App::melty::utils;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(check_output_and_execute execute check_file_exists execute_args);

use IPC::System::Simple qw(run);

sub check_output_and_execute {
    my ($output, $cmd) = @_;

    my $code;
    if ($output) {
        $cmd .= " -consumer avformat:$output acodec=libmp3lame vcodec=libx264 preset=ultrafast";

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

sub check_file_exists {
    my ($file) = @_;

    if (-f $file) {
        print "File '$file' exists. Overwrite ? (y/n): ";
        chomp(my $answer = <STDIN>);
        exit(0) unless lc($answer) eq 'y';
    }

    return 1;
}

sub execute {
    my ($cmd, $code) = @_;

    print "$cmd\n";

    $code->() if $code;

    if (!$ENV{APP_MELTY_DRY_RUN}) {
        system($cmd);

        die "FAIL\n" if $?;

        return $?;
    }

    return 1;
}

sub execute_args {
    my ($cmd, @args) = @_;

    print "$cmd @args\n";

    if (!$ENV{APP_MELTY_DRY_RUN}) {
        run($cmd, @args);
    }
}

1;
