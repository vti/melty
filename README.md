# NAME

melty - command-line video editor

# SYNOPSIS

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

# DESCRIPTION

`melty` is a command-line video editor. It is mainly a wrapper around `melt`.

# AUTHOR

Viacheslav Tykhanovskyi

# COPYRIGHT AND LICENSE

Copyright (C) 2014, Viacheslav Tykhanovskyi

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.


