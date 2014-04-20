package App::melty::extract_audio;

use strict;
use warnings;

use base 'App::melty::command';

use App::melty::utils qw(execute_args check_file_exists);

sub run {
    my $self = shift;
    my (%options) = @_;

    my @files = @{$options{'<files>'}};
    foreach my $file (@files) {
        die "Can't open file '$file': $!\n" unless -f $file;
    }

    my $output = $options{'--output'};

    my @args = qw/-hide-video/;
    push @args, @files;
    push @args, '-consumer', "avformat:$output", 'acodec=libmp3lame';
    push @args, '-progress';

    check_file_exists($output);

    execute_args('melt', @args);

    return $self;
}

1;
