package SysTicket::Model::User;

use strict;
use Moose;

use base 'SysTicket::Model::Base';

has 'db_model' => (
	is => 'rw',
	default => 'DB::User',
);

sub get_all {
	my ( $self, $c ) = @_;

	return [] unless $self->db_model;

	my @objects = $c->model( $self->db_model )->all;

	unshift @objects, {
		id   => 'null',
		name => 'Unassigned',
 	};

	return \@objects;
}

1;