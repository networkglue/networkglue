use utf8;
package NG::Schema::Result::Account;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NG::Schema::Result::Account

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

=head1 TABLE: C<accounts>

=cut

__PACKAGE__->table("accounts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 password

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 authentication

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "password",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "authentication",
  { data_type => "integer", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-02-24 01:06:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tH4iBnZiCuvwPi4MR1fPMA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
