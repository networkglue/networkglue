use utf8;
package NG::Schema::Result::DsAcsIdentitygroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NG::Schema::Result::DsAcsIdentitygroup

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

=head1 TABLE: C<ds_acs_identitygroups>

=cut

__PACKAGE__->table("ds_acs_identitygroups");

=head1 ACCESSORS

=head2 uid

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=head2 id

  data_type: 'integer'
  is_nullable: 1

=head2 source

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 128

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
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "id",
  { data_type => "integer", is_nullable => 1 },
  "source",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 128 },
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

=head2 ds_acs_users

Type: has_many

Related object: L<NG::Schema::Result::DsAcsUser>

=cut

__PACKAGE__->has_many(
  "ds_acs_users",
  "NG::Schema::Result::DsAcsUser",
  { "foreign.identitygroupname" => "self.uid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NpB2of9biTXWnGEpNAzoXw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
