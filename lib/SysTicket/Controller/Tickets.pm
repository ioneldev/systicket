package SysTicket::Controller::Tickets;
use Moose;
use namespace::autoclean;

use SysTicket::Util::ValidationEngine;
use SysTicket::Util::UserMessages;
use SysTicket::Model::Ticket;
use SysTicket::Model::Status; 
use SysTicket::Model::User;

BEGIN { extends 'Catalyst::Controller'; }

has 'ticket_model' => (
    is   => 'ro',
    isa  => 'SysTicket::Model::Ticket',
    lazy => 1,
    builder => '_build_ticket_model',
);

has 'status_model' => (
    is   => 'ro',
    isa  => 'SysTicket::Model::Status',
    lazy => 1,
    builder => '_build_status_model',
);

has 'user_model' => (
    is   => 'ro',
    isa  => 'SysTicket::Model::User',
    lazy => 1,
    builder => '_build_user_model',
);

sub _build_user_model {

    return SysTicket::Model::User->new();
}

sub _build_status_model {
    return SysTicket::Model::Status->new();
}

sub _build_ticket_model {

    return SysTicket::Model::Ticket->new();
}

=head1 NAME

SysTicket::Controller::Tickets

=head1 METHODS

=head2 base
 
Base controller. Used for loading status messages, and stashing common data
 
=cut

sub base :Chained('/') :PathPart('tickets') :CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->load_status_msgs;

    # Checking params in case the add function returns any errors.
    my $params = $c->request->params;

    if ( defined $params ) {
        foreach my $key ( keys %$params ) {
            if ( defined $params->{$key} ) {
                $c->stash( $key => $params->{$key} );
            }
        }
    }

    my $all_statuses = $self->status_model->get_all($c);
    $c->stash(
        statuses => $all_statuses,
    );
    
}

=head2 object
 
Object controller. Used for stashing the object, statuses and users for all
methods chaining this
 
=cut

sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    my $ticket_object = $self->ticket_model->get($c, $id);
    my $all_users     = $self->user_model->get_all($c);

    $c->stash(
        object   => $ticket_object,
        users    => $all_users,
    );
}

=head2 add_form
  
=cut

sub add_form :Chained('base') :PathPart('add_form') :Args(0) {
    my ($self, $c) = @_;

    my $all_users    = $self->user_model->get_all($c);
 
    $c->stash( users => $all_users );
}


sub list :Chained('base') :PathPart('list') :Args(0) {
    my ($self, $c) = @_;

    my $tickets = $self->ticket_model->get_all($c);
    
    $c->stash(
        tickets  => $tickets, 
        template => 'tickets/list.tt'
    );
}


=head2 add
 
Adding a new ticket
 
=cut
 
sub add :Chained('base') :PathPart('add') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $errors = {};

    my $validation_rules = {
        title         => { is_not_empty => 1, max_length => 255 },
        description   => { is_not_empty => 1 },
        status        => { is_not_empty => 1 },
        assigned_user => { is_not_empty => 1 },
    };

    # Validating input parameters.
    my $args   = $self->_validate_input_params($params, $errors, $validation_rules);

    if ( defined $errors->{message} ) {
        return $self->_redirect_to_page(
            $c,
            'add_form',
            $args,
            $errors
        );
    }

    # Validation successfully done. We can make the insert
    my $response = $self->ticket_model->add($c, $args);

    if ( defined $response->{error} ) {
        return $self->_redirect_to_page(
            $c,
            'add_form',
            $args,
            { message => SysTicket::Util::UserMessages::get_user_message('db_error', 'add_ticket') }
        );
    }
    
    return $self->_redirect_to_page(
        $c,
        'list',
        { message => SysTicket::Util::UserMessages::get_user_message('success', 'add_ticket') }
    );  
}

=head2 info
 
Getting the info about a ticket, replies included
 
=cut

sub info :Chained('object') :PathPart('info') :Args(0) {
    my ($self, $c ) = @_;

    my $object = $c->stash->{object};

    my $info = $self->ticket_model->build_ticket_info($c, $object);

    $c->stash(ticket_info => $info->{ticket}, template => 'tickets/info.tt');
}

=head2 add_reply
 
Adding a reply to a ticket
 
=cut

sub add_reply :Chained('object') :PathPart('add_reply') :Args(0) {
    my ($self, $c ) = @_;

    my $params = $c->request->params;
    my $errors = {};

    my $validation_rules = {
        reply => { is_not_empty => 1 },
    };

    # Validating input parameters.
    my $args   = $self->_validate_input_params($params, $errors, $validation_rules);

    my $object = $c->stash->{object};

    if ( defined $errors->{message} ) {
        my $info = $self->ticket_model->build_ticket_info($c, $object);
        $args->{ticket_info} = $info->{ticket};

        return $self->_redirect_to_page(
            $c,
            'info',
            $args,
            $errors,
            $object->id,
        );
    }

    my $response = $self->ticket_model->add_reply($c, $object, $args->{reply});

    if ( defined $response->{error} ) {
        return $self->_redirect_to_page(
            $c,
            'info',
            $args,
            { message => SysTicket::Util::UserMessages::get_user_message('db_error', 'add_reply') },
            $object->id,
        );
    }

    my $info = $self->ticket_model->build_ticket_info($c, $object);
    $args->{ticket_info} = $info->{ticket};

    $c->stash(ticket_info  => $info->{ticket}, template => 'tickets/info.tt');
}


=head2 edit
 
Editing a ticket
 
=cut

sub edit :Chained('object') :PathPart('edit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $errors = {};

    my $object = $c->stash->{object};

    my $validation_rules = {
        title         => { is_not_empty => 1, max_length => 255 },
        description   => { is_not_empty => 1 },
        status        => { is_not_empty => 1 },
        assigned_user => { is_not_empty => 1 },
    };


    # Validating input parameters.
    my $args   = $self->_validate_input_params($params, $errors, $validation_rules);

    if ( defined $errors->{message} ) {
        return $self->_redirect_to_page(
            $c,
            'edit_form',
            $args,
            $errors,
            $object->id,
        );
    }

    # Validation successfully done. We can make the insert
    my $response = $self->ticket_model->update($c, $object, $args);

    if ( defined $response->{error} ) {
        return $self->_redirect_to_page(
            $c,
            'info',
            $args,
            { message => SysTicket::Util::UserMessages::get_user_message('db_error', 'edit_ticket') },
            $object->id,
        );
    }
    
    return $self->_redirect_to_page(
        $c,
        'info',
        { message => SysTicket::Util::UserMessages::get_user_message('success', 'edit_ticket') },
        undef,
        $object->id,
    );   
}

=head2 edit_form
  
=cut

sub edit_form :Chained('object') :PathPart('edit_form') :Args(0) {
    my ($self, $c) = @_;

    $c->stash(template => 'tickets/edit_form.tt'); 
}

=head2 filter_by_status

Getting the list of tickets filtered
  
=cut

sub filter_by_status :Chained('base') :PathPart('filter_by_status') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;

    my $all_statuses = $c->stash->{statuses};

    my @valid_statuses = map { $_->id } @$all_statuses;

    my $errors = {};

    my $validation_rules = {
        status => { is_not_empty => 1, enum => \@valid_statuses },
    };

    # Validating input parameters.
    my $args   = $self->_validate_input_params($params, $errors, $validation_rules);

    if ( defined $errors->{message} ) {
        return $self->_redirect_to_page(
            $c,
            'list',
            $args,
            $errors
        );
    }

    my $response = $self->ticket_model->get_all_filtered($c, $args);

    if ( defined $response->{error} ) {
        return $self->_redirect_to_page(
            $c,
            'list',
            $args,
            { message => SysTicket::Util::UserMessages::get_user_message('db_error', 'filter_by_status') }
        );
    }
     
    $c->stash(tickets  => $response->{tickets}, template => 'tickets/list.tt');
}

sub _validate_input_params {
    my ( $self, $params, $errors, $validation_rules ) = @_;

    my $engine = SysTicket::Util::ValidationEngine->new({
        field_and_rules => $validation_rules,
    });

    return $engine->validate($params, $errors);
}

sub _add_status_message {
    my ( $self, $c, $success, $errors ) = @_;
    
    my $args = {};

    if ( defined $success && defined $success->{message} ) {
        $args->{mid} = $c->set_status_msg( $success->{message} );
    }

    if ( defined $errors && defined $errors->{message} ) {
        $args->{mid} = $c->set_error_msg( $errors->{message} );

        delete $errors->{message};

        foreach my $field ( keys %$errors ) {
            $args->{ "error_$field" } = 1;
        }

        if ( defined $success ) {
            foreach my $field ( keys %$success ) {
                $args->{ $field } = $success->{$field};
            }
        }
    }

    return $args;
}

sub _redirect_to_page {
    my ( $self, $c, $page, $success, $errors, $id ) = @_;
    
    my $args = $self->_add_status_message($c, $success, $errors);

    if ( defined $id ) {
        $c->response->redirect(
            $c->uri_for(
                $self->action_for($page),
                [$id],
                $args
            )
        );
    }
    else {
        $c->response->redirect(
            $c->uri_for(
                $self->action_for($page),
                $args
            )
        );
    }    
}
=encoding utf8

=head1 AUTHOR

Ionel

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
