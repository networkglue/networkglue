use utf8;
package NG::Schema::Result::DsIseInternaluser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NG::Schema::Result::DsIseInternaluser

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

=head1 TABLE: C<ds_ise_internalusers>

=cut

__PACKAGE__->table("ds_ise_internalusers");

=head1 ACCESSORS

=head2 pk_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'ds_ise_internalusers_pk_id_seq'

=head2 id

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 password

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 firstname

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 lastname

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 identitygroups

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 128

=head2 changepassword

  data_type: 'boolean'
  is_nullable: 1

=head2 expirydateenabled

  data_type: 'boolean'
  is_nullable: 1

=head2 expirydate

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 enablepassword

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 enabled

  data_type: 'boolean'
  is_nullable: 1

=head2 passwordidstore

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
  "pk_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "ds_ise_internalusers_pk_id_seq",
  },
  "id",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "password",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "firstname",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "lastname",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "identitygroups",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 128 },
  "changepassword",
  { data_type => "boolean", is_nullable => 1 },
  "expirydateenabled",
  { data_type => "boolean", is_nullable => 1 },
  "expirydate",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "enablepassword",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "enabled",
  { data_type => "boolean", is_nullable => 1 },
  "passwordidstore",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "status",
  { data_type => "integer", is_nullable => 1 },
  "checksum",
  { data_type => "varchar", is_nullable => 1, size => 64 },
);

=head1 PRIMARY KEY

=over 4

=item * L</pk_id>

=back

=cut

__PACKAGE__->set_primary_key("pk_id");

=head1 RELATIONS

=head2 identitygroup

Type: belongs_to

Related object: L<NG::Schema::Result::DsIseIdentitygroup>

=cut

__PACKAGE__->belongs_to(
  "identitygroup",
  "NG::Schema::Result::DsIseIdentitygroup",
  { id => "identitygroups" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-02-09 12:04:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nLlW0J/xEDRO6uxd133B4A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
