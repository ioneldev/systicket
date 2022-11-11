package SysTicket;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
#   Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple

    StackTrace

    Session
    Session::Store::File
    Session::State::Cookie

    StatusMessage
/;

#TODO remove StackTrace before going live

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in systicket.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'SysTicket',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    encoding => 'UTF-8', # Setup request decoding and response encoding

    # Configure the view
    'View::HTML' => {
        #Set the location for TT files
        INCLUDE_PATH => [
            __PACKAGE__->path_to( 'root', 'src' ),
        ],
    },
);

# Start the application
__PACKAGE__->setup();

=encoding utf8

=head1 NAME

SysTicket - Simple ticketing system

=head1 SYNOPSIS

    script/systicket_server.pl

=head1 DESCRIPTION

=head1 SEE ALSO

L<SysTicket::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Ionel

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
