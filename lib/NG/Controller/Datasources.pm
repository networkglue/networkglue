package NG::Controller::Datasources;
use Mojo::Base 'Mojolicious::Controller';
use NG::Process::ACS;
use NG::Process::Intermapper;
use NG::Process::ISE;
use NG::Process::NA;

use Data::Dumper;

my %valid_datasources = ("acs" => "ACS", "ise" => "ISE", "intermapper" => "Intermapper", "na" => "NA");
                      
sub new_form { # GET /datasources/new - form to create a datasource   
  my $self = shift;
  $self->redirect_to('/login/') && return if !$self->session('logged_in');
  my $filter = "";
  $self->stash(filter => $filter);
  $self->stash(items => $self->items);  
  my $username = $self->session('username');
  $self->stash(username => $username);

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
  $self->redirect_to('/login/') && return if !$self->session('logged_in');
  my $id = $self->param("id");

  my $filter = "";
  my $filterheader = "";
  $self->stash(items => $self->items);
  $self->stash(filterheader => $filterheader);
  $self->stash(filter => $filter);
  my $username = $self->session('username');
  $self->stash(username => $username);

  my $rs = $self->db->resultset('DsSource');
  my $query_rs = $rs->search( { id => $id });
  my $source = $query_rs->first;
  my $ssl_check = $source->ssl ? " checked" : "";
  my $datasource = { id => $source->id, type => $source->type, hostname => $source->hostname, username => $source->username, password => $source->password,
                     ssl => $source->ssl, priority => $source->priority, ssl_check => $ssl_check };
  my $target = lc($source->type->shortname);
  if ($valid_datasources{$target})
  { $self->stash(datasource => $datasource); 
    $self->render("datasources/detail_$target", layout => 'datasources');
  } else
  { }
  # Add error handling here!
}

sub edit_form { # GET /datasources/123/edit - form to update a datasource
  my $self = shift;
  $self->redirect_to('/login/') && return if !$self->session('logged_in');
  my $id = $self->param("id");  
}

# This action will render a template
sub index { # GET /datasources - list of all datasources
  my $self = shift;
  $self->redirect_to('/login/') && return if !$self->session('logged_in');
  my $rs = $self->db->resultset('DsSource');
  my $query_rs = $rs->search();
  my $datasources = {};
  while (my $source = $query_rs->next)
  { $datasources->{$source->id} = $source;
  }

  my $filter = "";
  my $filterheader = "";
  $self->stash(items => $self->items);
  $self->stash(filterheader => $filterheader);
  $self->stash(filter => $filter);
  my $username = $self->session('username');
  $self->stash(username => $username);

  $self->stash(datasources => $datasources);
  $self->render('datasources/index', layout => 'datasources');
}

sub create { # POST /datasources - create new datasource
  my $self = shift;
  $self->redirect_to('/login/') && return if !$self->session('logged_in');
  
  my $hostname = $self->param("hostname");
  my $priority = $self->param("priority");
  my $username = $self->param("username");
  my $password = $self->param("password");  
  my $ssl = $self->param("ssl") || "0";  
  my $target = lc($self->param("target"));
  
  if ($valid_datasources{$target})
  { my $rs = $self->db->resultset('DsSource');
    my $query_rs = $rs->search();
    my $datasources = {};
    my $rs_type = $self->db->resultset('DsType');
    my $query_rstype = $rs_type->search( { shortname => $valid_datasources{$target} });
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
    $datasources->{$maxid}{"ssl"} = $ssl;
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
  $self->redirect_to('/login/') && return if !$self->session('logged_in');
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
  my $ssl = $self->param("ssl") || "0";  
  if ($valid_datasources{$target} && $datasources->{$id})
  { my $rs_type = $self->db->resultset('DsType');
    my $query_rstype = $rs_type->search( { shortname => $valid_datasources{$target} });
    my $type = $query_rstype->first;

    $datasources->{$id}->update({ username => $username, password => $password, hostname => $hostname, type => $type, priority => $priority, ssl => $ssl});
    $self->redirect_to("/datasources/$id");
  }
}

sub delete { # DELETE /datasources/123 - delete a datasource
  my $self = shift;
  $self->redirect_to('/login/') && return if !$self->session('logged_in');
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
  $self->redirect_to('/login/') && return if !$self->session('logged_in');
  my $id = $self->param("id");
  my $rs = $self->db->resultset('DsSource');
  my $query_rs = $rs->search( { id => $id });
  my $source = $query_rs->first;
  if ($source->type->shortname eq "ACS")
  { my $process = NG::Process::ACS->new("db" => $self->db, "cipher" => $self->cipher, "key" => $self->key, "salt" => $self->salt);
    $process->load_identitygroups;
    #$process->export_identitygroups;
    $process->load_users;
    #$process->export_users;
  }
  
  # Clean the GUI logic up
 if ($source->type->shortname eq "Intermapper")
  { my $process = NG::Process::Intermapper->new("db" => $self->db, "cipher" => $self->cipher, "key" => $self->key, "salt" => $self->salt);
    $process->load_users;
    #$process->export_users;
  }
  
  # Clean the GUI logic up
  if ($source->type->shortname eq "ISE")
  { my $process = NG::Process::ISE->new("db" => $self->db, "cipher" => $self->cipher, "key" => $self->key, "salt" => $self->salt);
    $process->load_identitygroups;
    $process->load_users;
    #$process->export_users;
  }
  # Clean the GUI logic up
  if ($source->type->shortname eq "NA")
  { my $process = NG::Process::NA->new("db" => $self->db, "cipher" => $self->cipher, "key" => $self->key, "salt" => $self->salt);
    #$process->load_identitygroups;
    $process->load_users;
    #$process->export_users;
  }

  $self->redirect_to("/datasources/");
}

# This action will render a template
sub import { # GET /datasources/import - show Import dialog
  my $self = shift;
  $self->redirect_to('/login/') && return if !$self->session('logged_in');
  my $rs = $self->db->resultset('DsSource');
  my $filter = "";
  my $filterheader = "";
  $self->stash(items => $self->items);
  $self->stash(filterheader => $filterheader);
  $self->stash(filter => $filter);

  my $query_rs = $rs->search();
  my $datasources = {};
  while (my $source = $query_rs->next)
  { $datasources->{$source->id} = $source;
  }

  $self->render('datasources/import', layout => 'datasources');
}

1;
