use utf8;
package NG::Schema::Result::DsAcsUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NG::Schema::Result::DsAcsUser

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

=head1 TABLE: C<ds_acs_users>

=cut

__PACKAGE__->table("ds_acs_users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 password

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 enablepassword

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 identitygroupname

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 enabled

  data_type: 'boolean'
  is_nullable: 1

=head2 passwordneverexpires

  data_type: 'boolean'
  is_nullable: 1

=head2 passwordtype

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 dateexceeds

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 dateexceedsenabled

  data_type: 'boolean'
  is_nullable: 1

=head2 status

  data_type: 'integer'
  is_nullable: 1

=head2 checksum

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 created

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 lastmodified

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "password",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "enablepassword",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "identitygroupname",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "enabled",
  { data_type => "boolean", is_nullable => 1 },
  "passwordneverexpires",
  { data_type => "boolean", is_nullable => 1 },
  "passwordtype",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "dateexceeds",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "dateexceedsenabled",
  { data_type => "boolean", is_nullable => 1 },
  "status",
  { data_type => "integer", is_nullable => 1 },
  "checksum",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "created",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "lastmodified",
  { data_type => "varchar", is_nullable => 1, size => 32 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 identitygroupname

Type: belongs_to

Related object: L<NG::Schema::Result::DsAcsIdentitygroup>

=cut

__PACKAGE__->belongs_to(
  "identitygroupname",
  "NG::Schema::Result::DsAcsIdentitygroup",
  { id => "identitygroupname" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-02-09 12:04:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sslmAlq73hGUT/h5YWUECQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
