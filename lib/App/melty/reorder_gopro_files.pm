package App::melty::reorder_gopro_files;

use strict;
use warnings;

use base 'App::melty::command';

sub run {
    my $self = shift;
    my (%options) = @_;

    my $files = $options{'<files>'};
    foreach my $file (@$files) {
        die "Can't open file '$file': $!\n" unless -f $file;
    }

    my $force = $options{'--force'};

    warn "Files are NOT really renamed. Use --force to actually rename files.\n"
      unless $force;

    foreach my $file (@$files) {
        if ($file =~ m/^GOPR(\d+?)\.(.*)$/) {
            $self->_move($file, "GP$1-00.$2", $force);
        }
        elsif ($file =~ m/GP(\d{2})(\d+)\.(.*)$/) {
            $self->_move($file, "GP$2-$1.$3", $force);
        }
        else {
            warn "Do not know what to do with '$file'\n";
        }
    }

    return $self;
}

sub _move {
    my $self = shift;
    my ($old_file, $new_file, $force) = @_;

    warn "Moving '$old_file' to '$new_file'\n";
    rename $old_file, $new_file if $force;
}

1;
