package App::melty::beep;

use strict;
use warnings;

use base 'App::melty::command';

use File::Temp ();
use App::melty::utils qw(execute_args normalize_time);
use App::melty::extract_audio;
use App::melty::concat;

sub run {
    my $self = shift;
    my (%options) = @_;

    my $file = $options{'<file>'};
    die "Can't open file '$file': $!\n" unless -f $file;

    my $start = normalize_time($options{'<start>'});
    my $end   = normalize_time($options{'<end>'});

    my $in     = $self->_to_seconds($start);
    my $out    = $self->_to_seconds($end);
    my $length = $out - $in;

    my $raw_audio         = File::Temp::tmpnam() . '.mp3';
    my $extract_audio_cmd = App::melty::extract_audio->new;
    $extract_audio_cmd->run('<files>' => [$file], '--output' => $raw_audio);

    my $before = File::Temp::tmpnam() . '.mp3';
    execute_args('sox', $raw_audio, $before, 'trim', 0, $in);

    my $after = File::Temp::tmpnam() . '.mp3';
    execute_args('sox', $raw_audio, $after, 'trim', $out, -0.5);

    my $beep = File::Temp::tmpnam() . '.mp3';
    execute_args('sox', '-c', 2, '-n', $beep, 'synth', $length, 'sin', 1000);

    my $new_audio = File::Temp::tmpnam() . '.mp3';
    execute_args('sox', $before, $beep, $after, $new_audio);

    my $concat_cmd = App::melty::concat->new;
    $concat_cmd->run(
        '<files>'        => [$file],
        '--remove-audio' => 1,
        '--audio'        => $new_audio,
        '--output'       => $options{'--output'}
    );

    return $self;
}

sub _to_seconds {
    my $self = shift;
    my ($time) = @_;

    my ($hour, $min, $sec) = split /:/, $time;

    return $hour * 3600 + $min * 60 + $sec;
}

1;
