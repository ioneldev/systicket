use utf8;
package SysTicket::Schema::Result::TicketReply;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

SysTicket::Schema::Result::TicketReply

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<Ticket_Reply>

=cut

__PACKAGE__->table("Ticket_Reply");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 ticket_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 reply_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "ticket_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "reply_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 reply

Type: belongs_to

Related object: L<SysTicket::Schema::Result::Reply>

=cut

__PACKAGE__->belongs_to(
  "reply",
  "SysTicket::Schema::Result::Reply",
  { id => "reply_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 ticket

Type: belongs_to

Related object: L<SysTicket::Schema::Result::Ticket>

=cut

__PACKAGE__->belongs_to(
  "ticket",
  "SysTicket::Schema::Result::Ticket",
  { id => "ticket_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-10-22 00:53:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0hMAiFDXXCSW8rUWmJtALg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
