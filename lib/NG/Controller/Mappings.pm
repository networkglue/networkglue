package NG::Controller::Mappings;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

my %datasources = ( 1 => "Cisco ACS", 2 => "Intermapper", 3 => "Cisco ISE");

my %table = {"ACS" => { "Users" => ["name", "enabled", "enablepassword", "dateexceedsenabled", "dateexceeds", "identitygroupname"]
                      },
             "Intermapper" => {"Users" => ["name", "groups", "external"]
                              },
             "ISE" => { "Users" => ["name", "enabled", "enablepassword", "expirydateenabled", "expirydate","identitygroups","firstname","lastname","email"]}
};

# This action will render a template
sub show { # GET /mappings/123 - show mapping with id 123
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");

  my $filter = "";
  my $filterheader = "";
  $self->stash(items => $self->items);
  $self->stash(filterheader => $filterheader);
  $self->stash(filter => $filter);
  my $username = $self->session('username');
  $self->stash(username => $username);

  $self->render('mappings/detail', layout => 'mappings');
}

sub edit_form { # GET /mappings/123/edit - form to update a mapping
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");  
}

# This action will render a template
sub index { # GET /mappings - list of all mappings
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $mappings = undef;
  my $mapping_rs = $self->db->resultset('Mapping');
  my $query_rs = $mapping_rs->search;
  while (my $mapping = $query_rs->next)
  { $mappings->{$mapping->id}{"id"} = $mapping->id if $mapping->id;
    $mappings->{$mapping->id}{"source_ds"} = $datasources{$mapping->source_ds} if $mapping->source_ds;
    $mappings->{$mapping->id}{"source_table"} = $mapping->source_table if $mapping->source_table;
    $mappings->{$mapping->id}{"source_field"} = $mapping->source_field if $mapping->source_field;
    $mappings->{$mapping->id}{"destination_ds"} = $datasources{$mapping->destination_ds} if $mapping->destination_ds;
    $mappings->{$mapping->id}{"destination_table"} = $mapping->destination_table if $mapping->destination_table;
    $mappings->{$mapping->id}{"destination_field"} = $mapping->destination_field if $mapping->destination_field;

    #$self->app->log->debug(Dumper \$mapping->source_table);
  }

  my $filter = "";
  my $filterheader = "";
  $self->stash(items => $self->items);
  $self->stash(filterheader => $filterheader);
  $self->stash(filter => $filter);
  my $username = $self->session('username');
  $self->stash(username => $username);
  
  $self->stash(mappings => $mappings);
  $self->render('mappings/index', layout => 'mappings');
}

sub new_form { # GET /mappings/new - form to create a mappings
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $filter = "";
  my $filterheader = "";
  $self->stash(items => $self->items);
  $self->stash(filterheader => $filterheader);
  $self->stash(filter => $filter);
  my $username = $self->session('username');
  $self->stash(username => $username);

  $self->render('mappings/create', layout => 'mappings');
}

sub update { # PUT /mappings/123 - update a mapping
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");    
}


sub delete { # DELETE /mappings/123 - delete a mapping
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");      
}

1;
