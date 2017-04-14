use utf8;
package NG::Schema::Result::Accountgroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NG::Schema::Result::Accountgroup

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

=head1 TABLE: C<accountgroups>

=cut

__PACKAGE__->table("accountgroups");

=head1 ACCESSORS

=head2 uid

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 id

  data_type: 'integer'
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "uid",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "id",
  { data_type => "integer", is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-01 00:33:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JRBPmrdTK1owAlN5nZ7Uug


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
