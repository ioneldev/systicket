package SysTicket::Util::UserMessages;

use strict;

my $messages = {
	'success' => {
		'add_ticket'  => 'Successfully added a new ticket.',
		'edit_ticket' => 'Successfully updated the ticket.',
	},
	'db_error' => {
		'add_ticket'       => 'Failed to add a new ticket. Something went wrong with the database insert.',
		'edit_ticket'      => 'Failed to edit the ticket. Something went wrong with the database update.',
		'filter_by_status' => 'Failed to filter by status. Something went wrong with the database get.',
		'add_reply'        => 'Failed to add a new reply. Something went wrong with the database insert',
	},
	'validation_failed' => {
		'is_not_empty'  => 'Field needs to be not empty.',
		'enum'          => 'Field needs to be one of the following ( %s ).',
		'max_length'    => 'Field needs to have less than %d characters.',
	},
};

sub get_user_message {
	my ( $status, $action ) = @_;

	return $messages->{ $status }->{ $action };
}