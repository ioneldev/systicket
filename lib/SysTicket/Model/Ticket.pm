package SysTicket::Model::Ticket;

use strict;
use Moose;

use base 'SysTicket::Model::Base';

has 'db_model' => (
	is => 'rw',
	default => 'DB::Ticket',
);

sub add {
	my ( $self, $c, $args ) = @_;

	undef $args->{assigned_user} if $args->{assigned_user} eq 'null';

	my $ticket;

	local $@; undef $@;

	eval {
		$ticket = $c->model( $self->db_model )->create( $args );
		1;
	};

	if ( $@ ) {
		$c->log->error("Failed to insert a ticket.");
		return { error => 1 };
	}
	else {
		return { success => 1, ticket => $ticket };
	}
}

sub update {
	my ( $self, $c, $object, $args ) = @_;

	undef $args->{assigned_user} if $args->{assigned_user} eq 'null';

	my $ticket;

	local $@; undef $@;

	eval {
		$ticket = $object->update( $args );
		1;
	};

	if ( $@ ) {
		$c->log->error("Failed to update the ticket.");
		return { error => 1 };
	}
	else {
		return { success => 1, ticket => $ticket };
	}
}

sub build_ticket_info {
	my ( $self, $c, $raw_object, $without_replies ) = @_;

	my $ticket = {
		id => $raw_object->id,
		title => $raw_object->title,
		description => $raw_object->description,
		status => $raw_object->status,
		assigned_user => defined $raw_object->assigned_user 
							? $raw_object->assigned_user 
							: { name => 'Unassigned', id => 'null' },
	};

	local $@; undef $@;

	eval {
		unless ( defined $without_replies ) {
			my $replies = [];
			foreach my $item ( $raw_object->ticket_replies->all ) {
				push @$replies, $item->reply;
			}

			$ticket->{replies} = $replies;
		}
		1;
	};

	if ( $@ ) {
		$c->log->error("Failed to get ticket info.");
		return { error => 1 };
	}
	else {
		return { success => 1, ticket => $ticket };
	}
}

sub get_all_filtered {
	my ( $self, $c, $filter ) = @_;

	unless ( defined $self->db_model ) {
		$c->log->error("Failed to get filtered tickets. Model is not defined");
		return { error => 1 };
	}

	my @objects;

	local $@; undef $@;

	eval {
		@objects = $c->model( $self->db_model )->search( $filter )->all;
		1;
	};

	if ( $@ ) {
		$c->log->error("Failed to get filtered tickets.");
		return { error => 1 };
	}
	else {
		return { success => 1, tickets => \@objects };
	}
}

sub add_reply {
	my ( $self, $c, $raw_object, $reply ) = @_;

	unless ( defined $raw_object ) {
		$c->log->error("Failed to add a reply. Ticket object is not defined");
		return { error => 1 };
	}

	unless ( defined $reply ) {
		$c->log->error("Failed to add a reply. Reply is not defined");
		return { error => 1 };
	}

	local $@; undef $@;

	eval {
		my $reply_obj = $c->model('DB::Reply')->create({message => $reply});

		$c->model('DB::TicketReply')->create({
			ticket_id => $raw_object->id, 
			reply_id => $reply_obj->id}
		);
		1;
	};

	if ( $@ ) {
		$c->log->error("Failed to add a reply to ticket.");
		return { error => 1 };
	}
	else {
		return { success => 1 };
	}
}

1;