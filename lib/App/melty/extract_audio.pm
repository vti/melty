package App::melty::extract_audio;

use strict;
use warnings;

use base 'App::melty::command';

use App::melty::utils qw(check_output_and_execute);

sub run {
    my $self = shift;
    my (%options) = @_;

    my @files = @{$options{'<files>'}};
    foreach my $file (@files) {
        die "Can't open file '$file': $!\n" unless -f $file;
    }

    my $cmd = 'melt -hide-video ';

    $cmd .= join ' ', @files;

    check_output_and_execute($options{'--output'}, $cmd);

    return $self;
}

1;
