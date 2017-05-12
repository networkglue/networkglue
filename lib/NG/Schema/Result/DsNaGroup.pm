use utf8;
package NG::Schema::Result::DsNaGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NG::Schema::Result::DsNaGroup

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

=head1 TABLE: C<ds_na_groups>

=cut

__PACKAGE__->table("ds_na_groups");

=head1 ACCESSORS

=head2 uid

  data_type: 'varchar'
  is_nullable: 0
  size: 72

=head2 source

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 usergroupcustom3

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 comments

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 usergroupcustom1

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 required

  data_type: 'boolean'
  is_nullable: 1

=head2 distinguishedname

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 createdate

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 usergroupname

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 usergroupid

  data_type: 'integer'
  is_nullable: 1

=head2 usergroupcustom2

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 devicegroup2id

  data_type: 'integer'
  is_nullable: 1

=head2 devicegroup3id

  data_type: 'integer'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 devicegroup1id

  data_type: 'integer'
  is_nullable: 1

=head2 usergroupcustom4

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 usergroupcustom6

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 lastmodifieddate

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 usergroupcustom5

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
  "usergroupcustom3",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "comments",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "usergroupcustom1",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "required",
  { data_type => "boolean", is_nullable => 1 },
  "distinguishedname",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "createdate",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "usergroupname",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "usergroupid",
  { data_type => "integer", is_nullable => 1 },
  "usergroupcustom2",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "devicegroup2id",
  { data_type => "integer", is_nullable => 1 },
  "devicegroup3id",
  { data_type => "integer", is_nullable => 1 },
  "description",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "devicegroup1id",
  { data_type => "integer", is_nullable => 1 },
  "usergroupcustom4",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "usergroupcustom6",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "lastmodifieddate",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "usergroupcustom5",
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
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HQgMGg4+xHSx+txIcGnfOQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
