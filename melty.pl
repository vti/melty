#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use File::Temp ();

my $faded     = 0;
my $watermark = '';
my $audio;
my $remove_audio = 0;
my $output       = '';

if (-e '.meltyrc') {
    my $rc = do { local $/; open my $fh, '<', '.meltyrc' or die $!; <$fh> };
    my @options = split /(?:,|\s+)/, $rc;
    unshift @ARGV, @options;
}

GetOptions(
    "watermark=s"  => \$watermark,
    "faded"        => \$faded,
    "audio=s"      => \$audio,
    "remove-audio" => \$remove_audio,
    "output"       => \$output,
) or die("Error in command line arguments\n");

my (@files) = @ARGV;
die "Usage: <file1> <file2> ... " unless @files;

my $tempdir = File::Temp->newdir(CLEANUP => 0);

my $cmd = 'melt -color:black -progress ';

if ($remove_audio) {
    $cmd .= ' -hide-audio ';
}

if ($faded) {
    my $black_length = '15';
    my $mixer_length = '60';

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

if ($audio) {
    $cmd .= qq{ -track -hide-video avformat:$audio -attach transition:mix };
}

if ($output) {
    $cmd .= " -consumer avformat:$output vcodec=libx264 preset=ultrafast";

    print $cmd, "\n";

    if (-f $output) {
        print "$output exists. Overwrite ? (y/n): ";
        chomp(my $answer = <STDIN>);
        exit(0) unless lc($answer) eq 'y';
    }
}
else {
    print $cmd, "\n";
}

system $cmd;

sub preprocess {
    my $file = shift;

    return $file unless $file =~ m/\.txt$/;

    my $text = do { local $/; open my $fh, '<', $file or die $!; <$fh> };

    $text =~ s{^\s+}{};
    $text =~ s{\s+$}{};
    $text =~ s{\r?\n}{\\n}g;

    my $image_file = generate_temp_name('.png');

    my $cmd =
        qq{convert -background black -fill white }
      . qq{ -colorspace RGB -depth 32 }
      . qq{ -font 'Droid-Serif-Regular' -pointsize 80 }
      . qq{ -size 1920x1080 -gravity Center caption:'$text' }
      . qq{ 'PNG32:$image_file'};
    run($cmd);

    my $video_file = generate_temp_name('.mp4');

    $cmd = qq{avconv -v quiet -loop 1 -t 00:00:05 -i $image_file }
      . qq{ -r 30 -vcodec libx264 '$video_file'};
    run($cmd);

    return "$video_file";
}

sub run {
    my $cmd = shift;

    print "$cmd\n";
    system($cmd);

    die "FAIL\n" if $?;
}

sub generate_temp_name {
    my ($suffix) = @_;

    my $file = '';
    $file .= int(rand(10)) for 1 .. 16;
    $file .= $suffix;

    return "$tempdir/$file";
}
