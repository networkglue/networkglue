use utf8;
package NG::Schema::Result::DsNaUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NG::Schema::Result::DsNaUser

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

=head1 TABLE: C<ds_na_users>

=cut

__PACKAGE__->table("ds_na_users");

=head1 ACCESSORS

=head2 uid

  data_type: 'varchar'
  is_nullable: 0
  size: 72

=head2 source

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 emailaddress

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 comments

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 userid

  data_type: 'integer'
  is_nullable: 1

=head2 distinguishedname

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 allowfailover

  data_type: 'boolean'
  is_nullable: 1

=head2 userpassword

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 timezone

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 firstname

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 useaaaloginforproxy

  data_type: 'boolean'
  is_nullable: 1

=head2 aaapassword

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 usercustom2

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 devicegroup1id

  data_type: 'integer'
  is_nullable: 1

=head2 privilegelevel

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 passwordoption

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 requireduser

  data_type: 'boolean'
  is_nullable: 1

=head2 lastlogindate

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 aaausername

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 ticketnumber

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 usercustom1

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 passwordlastmodifieddate

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 createdate

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 lastname

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 userpasswordunhashed

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 devicegroup3id

  data_type: 'integer'
  is_nullable: 1

=head2 devicegroup2id

  data_type: 'integer'
  is_nullable: 1

=head2 usercustom4

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 usercustom5

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 usercustom6

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 lastmodifieddate

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 usercustom3

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 na_status

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
  "source",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "emailaddress",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "comments",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "userid",
  { data_type => "integer", is_nullable => 1 },
  "distinguishedname",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "allowfailover",
  { data_type => "boolean", is_nullable => 1 },
  "userpassword",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "timezone",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "firstname",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "useaaaloginforproxy",
  { data_type => "boolean", is_nullable => 1 },
  "aaapassword",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "usercustom2",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "devicegroup1id",
  { data_type => "integer", is_nullable => 1 },
  "privilegelevel",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "passwordoption",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "requireduser",
  { data_type => "boolean", is_nullable => 1 },
  "lastlogindate",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "aaausername",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "status",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "ticketnumber",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "usercustom1",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "passwordlastmodifieddate",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "createdate",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "lastname",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "userpasswordunhashed",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "devicegroup3id",
  { data_type => "integer", is_nullable => 1 },
  "devicegroup2id",
  { data_type => "integer", is_nullable => 1 },
  "usercustom4",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "usercustom5",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "usercustom6",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "lastmodifieddate",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "usercustom3",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "na_status",
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


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2017-05-11 11:25:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bhbXewwleMRQJNUbWTekrw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
