package NG::Controller::Datasources;
use Mojo::Base 'Mojolicious::Controller';
use NG::Process::ACS;

my %valid_datasources = ("acs" => "ACS", "ise" => "ISE", "intermapper" => "Intermapper");
                      
sub new_form { # GET /datasources/new - form to create a datasource   
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $target = lc($self->param("target"));
  if ($valid_datasources{$target})
  { $self->render("datasources/create_$target", layout => 'datasources');
  } else
  { }
  # Add error handling here!
}

# This action will render a template
sub show { # GET /datasources/123 - show datasource with id 123
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");
  my $rs = $self->db->resultset('DsSource');
  my $query_rs = $rs->search( { id => $id });
  my $datasource = $query_rs->first;
  my $target = lc($datasource->type->shortname);
  if ($valid_datasources{$target})
  { $self->stash(datasource => $datasource); 
    $self->render("datasources/detail_$target", layout => 'datasources');
  } else
  { }
  # Add error handling here!
}

sub edit_form { # GET /datasources/123/edit - form to update a datasource
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");  
}

# This action will render a template
sub index { # GET /datasources - list of all datasources
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $rs = $self->db->resultset('DsSource');
  my $query_rs = $rs->search();
  my $datasources = {};
  while (my $source = $query_rs->next)
  { $datasources->{$source->id} = $source;
  }
  $self->stash(datasources => $datasources);
  $self->render('datasources/index', layout => 'datasources');
}

sub create { # POST /datasources - create new datasource
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  
  my $hostname = $self->param("hostname");
  my $priority = $self->param("priority");
  my $username = $self->param("username");
  my $password = $self->param("password");  
  my $target = lc($self->param("target"));
  
  if ($valid_datasources{$target})
  { my $rs = $self->db->resultset('DsSource');
    my $query_rs = $rs->search();
    my $datasources = {};
    my $rs_type = $self->db->resultset('DsType');
    my $query_rstype = $rs_type->search( shortname => $valid_datasources{$target});
    my $type = $query_rstype->first;

    while (my $source = $query_rs->next)
    { $datasources->{$source->id} = $source;
    }
    my %datasources = %{ $datasources };
    my @ids = sort { $a <=> $b } keys %datasources;
    my $maxid = pop @ids;
    $maxid++;
    $datasources->{$maxid}{"hostname"} = $hostname;
    $datasources->{$maxid}{"username"} = $username;
    $datasources->{$maxid}{"password"} = $password;
    $datasources->{$maxid}{"priority"} = $priority;
    $datasources->{$maxid}{"id"} = $maxid;
    $datasources->{$maxid}{"type"} = $type;
    $self->db->resultset('DsSource')->create($datasources->{$maxid});
    $self->redirect_to("/datasources/");
  } else
  { }
  # Add error handling here!
}

sub update { # PUT /datasources/123 - update a datasource
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $rs = $self->db->resultset('DsSource');
  my $query_rs = $rs->search();
  my $datasources = {};
  while (my $source = $query_rs->next)
  { $datasources->{$source->id} = $source;
  }

  my $id = $self->param("id");
  my $username = $self->param("username");
  my $password = $self->param("password");  
  my $hostname = $self->param("hostname");
  my $priority = $self->param("priority");
  my $target = lc($self->param("target"));
  if ($valid_datasources{$target} && $datasources->{$id})
  { my $rs_type = $self->db->resultset('DsType');
    my $query_rstype = $rs_type->search( { shortname => $valid_datasources{$target} });
    my $type = $query_rstype->first;

    $datasources->{$id}->update({ username => $username, password => $password, hostname => $hostname, type => $type, priority => $priority});
    $self->redirect_to("/datasources/$id");
  }
}

sub delete { # DELETE /datasources/123 - delete a datasource
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $rs = $self->db->resultset('DsSource');
  my $query_rs = $rs->search();
  my $datasources = {};
  while (my $source = $query_rs->next)
  { $datasources->{$source->id} = $source;
  }

  my $id = $self->param("id");
  if ($datasources->{$id})
  { $datasources->{$id}->delete;
    delete($datasources->{$id});
  }
  $self->redirect_to("/datasources/");
}

sub synchronize { # GET /datasources/synchronize - Synchronize from DB 
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $process = NG::Process::ACS->new("db" => $self->db, "cipher" => $self->cipher, "key" => $self->key, "salt" => $self->salt);
  $process->load_identitygroups;
  $process->export_identitygroups;
  $process->load_users;
  $process->export_users;
  $self->redirect_to("/datasources/");
}


# This action will render a template
sub import { # GET /datasources/import - show Import dialog
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $rs = $self->db->resultset('DsSource');
  my $query_rs = $rs->search();
  my $datasources = {};
  while (my $source = $query_rs->next)
  { $datasources->{$source->id} = $source;
  }

  $self->render('datasources/import', layout => 'datasources');
}

1;
