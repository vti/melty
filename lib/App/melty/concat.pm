package App::melty::concat;

use strict;
use warnings;

use base 'App::melty::command';

use File::Temp ();
use App::melty::utils qw(check_output_and_execute execute);

sub run {
    my $self = shift;
    my (%options) = @_;

    my @files = @{$options{'<files>'}};
    foreach my $file (@files) {
        die "Can't open file '$file': $!\n" unless -f $file;
    }

    my $cmd = 'melt -color:black -progress ';

    if ($options{'--remove-audio'}) {
        $cmd .= ' -hide-audio ';
    }

    if ($options{'--faded'}) {
        my $black_length = '15';
        my $mixer_length = '60';

        foreach my $file (@files) {
            $file = $self->_preprocess($file);

            $cmd .=
                " color:black out=$black_length "
              . $file
              . " -mix $mixer_length -mixer luma -mixer mix:-1 "
              . " color:black out=$black_length "
              . " -mix $mixer_length -mixer luma -mixer mix:-1 ";
        }
    }
    else {
        foreach my $file (@files) {
            $file = $self->_preprocess($file);

            $cmd .= ' ' . $file . ' ';
        }
    }

    if (my $wm = $options{'--watermark'}) {
        die "Can't open file '$wm': $!\n" unless -f $wm;
        $cmd .= " -filter watermark:$wm ";
    }

    if (my $au = $options{'--audio'}) {
        die "Can't open file '$au': $!\n" unless -f $au;
        $cmd .= qq{ -track -hide-video avformat:$au -attach transition:mix };
    }

    check_output_and_execute($options{'--output'}, $cmd);

    return $self;
}

sub _tempdir {
    my $self = shift;

    $self->{tempdir} ||= File::Temp->newdir;

    return $self->{tempdir};
}

sub _preprocess {
    my $self = shift;
    my ($file) = @_;

    return $file unless $file =~ m/\.txt$/;

    my $text = do { local $/; open my $fh, '<', $file or die $!; <$fh> };

    $text =~ s{^\s+}{};
    $text =~ s{\s+$}{};
    $text =~ s{\r?\n}{\\n}g;

    my $image_file = $self->_generate_temp_name('.png');

    my $cmd =
        qq{convert -background black -fill white }
      . qq{ -colorspace RGB -depth 32 }
      . qq{ -font 'Droid-Serif-Regular' -pointsize 80 }
      . qq{ -size 1920x1080 -gravity Center caption:'$text' }
      . qq{ 'PNG32:$image_file'};
    execute($cmd);

    my $video_file = $self->_generate_temp_name('.mp4');

    $cmd = qq{avconv -v quiet -loop 1 -t 00:00:05 -i $image_file }
      . qq{ -r 30 -vcodec libx264 '$video_file'};
    execute($cmd);

    return "$video_file";
}

sub _generate_temp_name {
    my $self = shift;
    my ($suffix) = @_;

    my $file = '';
    $file .= int(rand(10)) for 1 .. 16;
    $file .= $suffix;

    my $tempdir = $self->_tempdir;

    return "$tempdir/$file";
}

1;
