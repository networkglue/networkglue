package NG::Controller::Syncrules;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

my %table = {"ACS" => { "Users" => ["name", "enabled", "enablepassword", "dateexceedsenabled", "dateexceeds", "identitygroupname"]
                      },
             "Intermapper" => {"Users" => ["name", "groups", "external"]
                              },
             "ISE" => { "Users" => ["name", "enabled", "enablepassword", "expirydateenabled", "expirydate","identitygroups","firstname","lastname","email"]}
};

# This action will render a template
sub show { # GET /syncrules/123 - show mapping with id 123
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

  $self->render('syncrules/detail', layout => 'syncrules');
}

sub edit_form { # GET /syncrules/123/edit - form to update a mapping
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");  
}

# This action will render a template
sub index { # GET /syncrules - list of all syncrules
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $syncrules = undef;

  my $sources_rs = $self->db->resultset('DsSource');
  my $query_rs = $sources_rs->search;
  my %datasources = ();

  while (my $source = $query_rs->next)
  { $datasources{$source->id} = $source;
  }
  
  my $syncrule_rs = $self->db->resultset('Syncrule');
  $query_rs = $syncrule_rs->search;
  while (my $syncrule = $query_rs->next)
  { $syncrules->{$syncrule->id}{"id"} = $syncrule->id if $syncrule->id;
    $syncrules->{$syncrule->id}{"source_ds"} = $datasources{$syncrule->source_ds} if $syncrule->source_ds;
    $syncrules->{$syncrule->id}{"destination_ds"} = $datasources{$syncrule->destination_ds} if $syncrule->destination_ds;
  }
    
  my $filter = "";
  my $filterheader = "";
  $self->stash(items => $self->items);
  $self->stash(filterheader => $filterheader);
  $self->stash(filter => $filter);
  my $username = $self->session('username');
  $self->stash(username => $username);
  $self->stash(syncrules => $syncrules);
  $self->render('syncrules/index', layout => 'syncrules');
}

sub new_form { # GET /syncrules/new - form to create a syncrules
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $filter = "";
  my $filterheader = "";
  $self->stash(items => $self->items);
  $self->stash(filterheader => $filterheader);
  $self->stash(filter => $filter);
  my $username = $self->session('username');
  $self->stash(username => $username);

  $self->render('syncrules/create', layout => 'syncrules');
}

sub update { # PUT /syncrules/123 - update a mapping
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");    
}


sub delete { # DELETE /syncrules/123 - delete a mapping
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");      
}

1;
