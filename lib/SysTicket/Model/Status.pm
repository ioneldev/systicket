package SysTicket::Model::Status;

use strict;
use Moose;

use base 'SysTicket::Model::Base';

has 'db_model' => (
	is => 'rw',
	default => 'DB::Status',
);

1;