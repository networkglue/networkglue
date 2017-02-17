use utf8;
package NG::Schema::Result::DsType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NG::Schema::Result::DsType

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

=head1 TABLE: C<ds_types>

=cut

__PACKAGE__->table("ds_types");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 shortname

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "shortname",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 ds_sources

Type: has_many

Related object: L<NG::Schema::Result::DsSource>

=cut

__PACKAGE__->has_many(
  "ds_sources",
  "NG::Schema::Result::DsSource",
  { "foreign.type" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ds_tables

Type: has_many

Related object: L<NG::Schema::Result::DsTable>

=cut

__PACKAGE__->has_many(
  "ds_tables",
  "NG::Schema::Result::DsTable",
  { "foreign.type" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-01-02 22:29:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qCt7sBCOIBK0ttL7TeqZVw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
