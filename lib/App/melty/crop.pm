package App::melty::crop;

use strict;
use warnings;

use base 'App::melty::command';

use File::Basename ();
use App::melty::utils qw(check_output_and_execute);

sub run {
    my $self = shift;
    my (%options) = @_;

    my $file  = $options{'<file>'};
    die "Can't open file '$file': $!\n" unless -f $file;

    my $start = $self->_normalize_time($options{'<start>'});
    my $end   = $self->_normalize_time($options{'<end>'});

    my $in  = $self->_to_seconds($start) * 30;
    my $out = $self->_to_seconds($end) * 30;

    my $cmd = "melt -progress $file in=$in out=$out ";

    check_output_and_execute($options{'--output'}, $cmd);

    return $self;
}

sub _normalize_time {
    my $self = shift;
    my ($time) = @_;

    my ($sec, $min, $hour) = reverse split /:/, $time;
    $sec  ||= 0;
    $min  ||= 0;
    $hour ||= 0;

    return sprintf('%02d:%02d:%02d', $hour, $min, $sec);
}

sub _to_seconds {
    my $self = shift;
    my ($time) = @_;

    my ($hour, $min, $sec) = split /:/, $time;

    return $hour * 3600 + $min * 60 + $sec;
}

1;
