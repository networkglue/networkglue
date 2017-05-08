use utf8;
package NG::Schema::Result::Syncrule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NG::Schema::Result::Syncrule

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

=head1 TABLE: C<syncrules>

=cut

__PACKAGE__->table("syncrules");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 source_ds

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 destination_ds

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 priority

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "source_ds",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "destination_ds",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
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

=head2 destination_d

Type: belongs_to

Related object: L<NG::Schema::Result::DsSource>

=cut

__PACKAGE__->belongs_to(
  "destination_d",
  "NG::Schema::Result::DsSource",
  { id => "destination_ds" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 source_d

Type: belongs_to

Related object: L<NG::Schema::Result::DsSource>

=cut

__PACKAGE__->belongs_to(
  "source_d",
  "NG::Schema::Result::DsSource",
  { id => "source_ds" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-26 09:52:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Aujo5kdAIVwWA2JWTpdtIw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
