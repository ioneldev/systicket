package SysTicket::Util::ValidationEngine;

use strict;
use Moose;
use SysTicket::Util::UserMessages;

=head1 NAME

SysTicket::Util::ValidationEngine

=head1 DESCRIPTION

Used to implement different types of validations.

=cut

has 'field_and_rules' => (
	is  => 'ro',
);

has 'supported_validations' => (
	is  => 'ro',
	builder => '_build_supported_validations',
);

has 'error_messages' => (
	is  => 'ro',
	builder => '_build_error_messages',
);

sub _build_supported_validations {
	return  {
    	is_not_empty  => \&_validate_not_empty,
    	enum          => \&_validate_enum,
    	max_length    => \&_validate_max_length,
	};
}

sub _build_error_messages {
	return  {
    	is_not_empty  => \&_is_not_empty_error_message,
    	enum          => \&_enum_error_message,
    	max_length    => \&_max_length_error_message,
	};
}

=head
	Main function that validates the input parameter.
	As input, this funtion takes the parameters coming from the form and an empty hashref for errors
	As output, the funtion will return a hashref with the valid parameters and populate the errors hashref
=cut
sub validate {
    my ( $self, $params, $errors ) = @_;

    my $supported_validations = $self->supported_validations;
    my $error_messages = $self->error_messages;

    my $args  = {};

    foreach my $field_name ( keys %{ $self->field_and_rules } ) {

        my $param = $params->{ $field_name };

        my $param_rules = $self->field_and_rules->{$field_name};
        
        my $validation_failed = 0;

        foreach my $rule ( keys %$param_rules ) {

            if ( defined $supported_validations->{ $rule } ) {
                my $result = $supported_validations->{ $rule }($param, $param_rules->{$rule});

                unless ( $result ) {
	                $validation_failed = 1 ;
	                $args->{$field_name . "_error_message"} = $error_messages->{$rule }($param_rules->{$rule});
	            }
            }
        }

        if ( $validation_failed ) {
        	$errors->{message} = "Validation failed for some fields.";
            $errors->{$field_name} = 1;
        }
        else {
        	$args->{$field_name} = $param;
        	
        }
    }

    return $args;
}

sub _validate_not_empty {
    my $param = shift;

    return 1 if ( defined $param && $param ne '' );

    return 0;
}

sub _validate_enum {
    my ( $param, $allowed ) = @_;

    return 1 if ( $param && grep { $_ eq $param } @$allowed );

    return 0;
}

sub _validate_max_length {
	my ( $param, $lenght ) = @_;

	return 1 if ( length $param <= $lenght );

	return 0;
}

sub _is_not_empty_error_message {
	return SysTicket::Util::UserMessages::get_user_message('validation_failed', 'is_not_empty');
}

sub _enum_error_message {
	my $allowed = shift;
	
	return sprintf(SysTicket::Util::UserMessages::get_user_message('validation_failed', 'enum'), join(',', @$allowed) );
}

sub _max_length_error_message {
	my $max_length = shift;

	return sprintf(SysTicket::Util::UserMessages::get_user_message('validation_failed', 'max_length'), $max_length );
}

1;