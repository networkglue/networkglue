use utf8;
package NG::Schema::Result::DsSource;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NG::Schema::Result::DsSource

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

=head1 TABLE: C<ds_sources>

=cut

__PACKAGE__->table("ds_sources");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 type

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 hostname

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 password

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 ssl

  data_type: 'integer'
  is_nullable: 1

=head2 priority

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "type",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "hostname",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "password",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "ssl",
  { data_type => "integer", is_nullable => 1 },
  "priority",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 ds_acs_identitygroups

Type: has_many

Related object: L<NG::Schema::Result::DsAcsIdentitygroup>

=cut

__PACKAGE__->has_many(
  "ds_acs_identitygroups",
  "NG::Schema::Result::DsAcsIdentitygroup",
  { "foreign.source" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ds_acs_users

Type: has_many

Related object: L<NG::Schema::Result::DsAcsUser>

=cut

__PACKAGE__->has_many(
  "ds_acs_users",
  "NG::Schema::Result::DsAcsUser",
  { "foreign.source" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ds_intermapper_users

Type: has_many

Related object: L<NG::Schema::Result::DsIntermapperUser>

=cut

__PACKAGE__->has_many(
  "ds_intermapper_users",
  "NG::Schema::Result::DsIntermapperUser",
  { "foreign.source" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ds_ise_identitygroups

Type: has_many

Related object: L<NG::Schema::Result::DsIseIdentitygroup>

=cut

__PACKAGE__->has_many(
  "ds_ise_identitygroups",
  "NG::Schema::Result::DsIseIdentitygroup",
  { "foreign.source" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ds_ise_internalusers

Type: has_many

Related object: L<NG::Schema::Result::DsIseInternaluser>

=cut

__PACKAGE__->has_many(
  "ds_ise_internalusers",
  "NG::Schema::Result::DsIseInternaluser",
  { "foreign.source" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 type

Type: belongs_to

Related object: L<NG::Schema::Result::DsType>

=cut

__PACKAGE__->belongs_to(
  "type",
  "NG::Schema::Result::DsType",
  { id => "type" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-25 23:41:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RQGoUHMbZzNmUzcPt70YuA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
