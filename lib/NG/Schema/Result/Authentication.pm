use utf8;
package NG::Schema::Result::Authentication;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NG::Schema::Result::Authentication

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<authentication>

=cut

__PACKAGE__->table("authentication");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 hostname

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 authkey

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 port

  data_type: 'varchar'
  is_nullable: 1
  size: 6

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 8

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "hostname",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "authkey",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "port",
  { data_type => "varchar", is_nullable => 1, size => 6 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 8 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-02-24 01:11:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xU3sIw3ANSlCXsOXvQ7bgw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
