#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use File::Temp ();
use Capture::Tiny qw(capture);

my $faded     = 0;
my $watermark = '';
GetOptions(
    "watermark=s" => \$watermark,
    "faded"       => \$faded
) or die("Error in command line arguments\n");

my $output = pop @ARGV;
my (@files) = @ARGV;
die "Usage: <file1> <file2> ... <output>" unless @files && $output;

my $tempdir = File::Temp->newdir;

my $cmd = 'melt ';

if ($faded) {
    my $black_length = '10';
    my $mixer_length = '15';

    foreach my $file (@files) {
        $file = preprocess($file);

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
        $file = preprocess($file);

        $cmd .= ' ' . $file . ' ';
    }
}

$cmd .= " -filter watermark:$watermark " if $watermark;

$cmd .= " -consumer avformat:$output vcodec=libx264 preset=ultrafast";

print $cmd, "\n";

if (-f $output) {
    print "$output exists. Overwrite ? (y/n): ";
    chomp(my $answer = <STDIN>);
    exit(0) unless lc($answer) eq 'y';
}

system $cmd;

sub preprocess {
    my $file = shift;

    return $file unless $file =~ m/\.txt$/;

    my $text = do { local $/; open my $fh, '<', $file or die $!; <$fh> };

    my $image_file = generate_temp_name('.png');

    my $cmd =
        qq{convert -background black -fill white }
      . qq{ -font 'Droid-Serif-Regular' -pointsize 80 }
      . qq{ -size 1920x1080 -gravity Center caption:'$text' }
      . qq{ '$image_file'};
    run($cmd);

    my $video_file = generate_temp_name('.mp4');

    $cmd = qq{avconv -v quiet -loop 1 -t 00:00:02 -i $image_file }
      . qq{ -r 30 -vcodec libx264 '$video_file'};
    run($cmd);

    return "$video_file";
}

sub run {
    my $cmd = shift;

    print "$cmd\n";
    system($cmd);
}

sub generate_temp_name {
    my ($suffix) = @_;

    my $file = '';
    $file .= int(rand(10)) for 1 .. 16;
    $file .= $suffix;

    return "$tempdir/$file";
}

__END__

=pod

melty is a melt/avconv helper that concatenates videos applying a watermark and
fading.

If a file is a text file (ends with C<.txt>) then it's converted to a centered
image and is converted to 2 seconds video.

Options:

=over

=item C<--watermark=s>

    --watermark image-with-watermark.png

    Apply a watermark.

=item C<--faded>

    --faded

    Concatenate videos applying fading effect.

=back

=cut
