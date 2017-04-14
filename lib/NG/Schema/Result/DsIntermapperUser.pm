use utf8;
package NG::Schema::Result::DsIntermapperUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NG::Schema::Result::DsIntermapperUser

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

=head1 TABLE: C<ds_intermapper_users>

=cut

__PACKAGE__->table("ds_intermapper_users");

=head1 ACCESSORS

=head2 uid

  data_type: 'varchar'
  is_nullable: 0
  size: 72

=head2 id

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 source

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 password

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 groups

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 external

  data_type: 'boolean'
  is_nullable: 1

=head2 guest

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 status

  data_type: 'integer'
  is_nullable: 1

=head2 checksum

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "uid",
  { data_type => "varchar", is_nullable => 0, size => 72 },
  "id",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "source",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "password",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "groups",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "external",
  { data_type => "boolean", is_nullable => 1 },
  "guest",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "status",
  { data_type => "integer", is_nullable => 1 },
  "checksum",
  { data_type => "varchar", is_nullable => 1, size => 64 },
);

=head1 PRIMARY KEY

=over 4

=item * L</uid>

=back

=cut

__PACKAGE__->set_primary_key("uid");

=head1 RELATIONS

=head2 source

Type: belongs_to

Related object: L<NG::Schema::Result::DsSource>

=cut

__PACKAGE__->belongs_to(
  "source",
  "NG::Schema::Result::DsSource",
  { id => "source" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-01 00:33:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/Vp25zcDvXLh+MxU1wOyew


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
