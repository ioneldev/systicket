use strict;
use warnings;

use SysTicket;

my $app = SysTicket->apply_default_middlewares(SysTicket->psgi_app);
$app;

