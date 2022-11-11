package SysTicket::Model::Base;

use strict;

use Moose;

sub get_all {
	my ( $self, $c ) = @_;

	return [] unless $self->db_model;

	my @objects = $c->model( $self->db_model )->all;

	return \@objects;
}


sub get {
	my ( $self, $c, $id ) = @_;

	return unless $self->db_model;

	my $object = $c->model( $self->db_model )->find( { id => $id });

	return $object;
}

1;