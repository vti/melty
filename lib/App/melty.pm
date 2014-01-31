package App::melty;

use strict;
use warnings;

our $VERSION = '0.01';

1;
__END__

=head1 NAME

melty - command-line video editor

=head1 SYNOPSIS

  melty concat              [--watermark=image.png]
                            [--faded]
                            [--audio=file.mp3]
                            [--remove-audio]
                            [--output=file.mp4]
                            <files>...
  melty extract-audio       [--output=file.mp3] <files>...
  melty crop                <start> <end> <file> [--output=file.mp4]
  melty reorder-gopro-files [--force] <files>...
  melty -h | --help
  melty --version

  -h | --help       Show this screen.

=head1 DESCRIPTION

C<melty> is a command-line video editor. It is mainly a wrapper around C<melt>.

=head1 AUTHOR

Viacheslav Tykhanovskyi

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014, Viacheslav Tykhanovskyi

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.


=cut
