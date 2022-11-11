use strict;
use warnings;
use Test::More;


use Catalyst::Test 'SysTicket';
use SysTicket::Controller::Tickets;

ok( request('/tickets/list')->is_success, 'Request should succeed' );
ok( request('/tickets/id/1/info')->is_success, 'Request should succeed' );
ok( request('/tickets/add_form')->is_success, 'Request should succeed' );
ok( request('/tickets/id/1/edit_form')->is_success, 'Request should succeed' );

done_testing();
