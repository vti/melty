use strict;
use warnings;

use Test::More;

local $ENV{APP_MELTY_DRY_RUN} = 1;

use App::melty::utils qw(execute);

ok(execute 'my_command');

done_testing;
