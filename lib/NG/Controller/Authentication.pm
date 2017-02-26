package NG::Controller::Authentication;
use Mojo::Base 'Mojolicious::Controller';
use NG::Process::ACS;

my %valid_authentications = ("tacacs" => "TACACS+", "radius" => "RADIUS");
                      
sub new_form { # GET /authentication/new - form to create an authentication    
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $target = lc($self->param("target"));
  if ($valid_authentications{$target})
  { $self->render("authentication/create_$target", layout => 'authentication');
  } else
  { }
  # Add error handling here!
}

# This action will render a template
sub show { # GET /authentication/123 - show authentication with id 123
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");
  my $rs = $self->db->resultset('Authentication');
  my $query_rs = $rs->search( { id => $id });
  my $authentication_rs  = $query_rs->first;
  my $target = lc($authentication_rs->type);
  if ($valid_authentications{$target})
  { my $authentication = { hostname => $authentication_rs->hostname,  authkey => $authentication_rs->authkey, port => $authentication_rs->port, id => $authentication_rs->id, type => $valid_authentications{$authentication_rs->type}};  
    $self->stash(authentication  => $authentication );
    $self->render("authentication/detail_$target", layout => 'authentication');
  } else
  { }
  # Add error handling here!
}

sub edit_form { # GET /authentication/123/edit - form to update an authentication 
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");  
}

# This action will render a template
sub index { # GET /authentication - list of all authentications
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $rs = $self->db->resultset('Authentication');
  my $query_rs = $rs->search();
  my $authentications = {};
  while (my $source = $query_rs->next)
  { $authentications->{$source->id} = {"hostname" => $source->hostname, "type" => $valid_authentications{$source->type}, "id" => $source->id };
  }
  $self->stash(authsources => $authentications);
  $self->render('authentication/index', layout => 'authentication');
}

sub create { # POST /authentication - create new authentication 
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  
  my $hostname = $self->param("hostname");
  my $authkey = $self->param("authkey");
  my $port = $self->param("port");
  my $target = lc($self->param("target"));
  
  if ($valid_authentications{$target})
  { my $rs = $self->db->resultset('Authentication');
    my $query_rs = $rs->search();
    my $authentications = {};

    while (my $source = $query_rs->next)
    { $authentications->{$source->id} = $source;
    }
    my %authentications = %{ $authentications };
    my @ids = sort { $a <=> $b } keys %authentications;
    my $maxid = pop @ids;
    $maxid++;
    $authentications->{$maxid}{"hostname"} = $hostname;
    $authentications->{$maxid}{"authkey"} = $authkey;
    $authentications->{$maxid}{"port"} = $port;
    $authentications->{$maxid}{"type"} = $target;
    $authentications->{$maxid}{"priority"} = 0;
    $self->db->resultset('Authentication')->create(
      { hostname => $hostname, authkey => $authkey, port => $port, id => $maxid, type => $target
      });
    $self->redirect_to("/authentication/");
  } else
  { }
  # Add error handling here!
}

sub update { # PUT /authentication/123 - update a authentication 
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $rs = $self->db->resultset('Authentication');
  my $query_rs = $rs->search();
  my $authentications = {};
  while (my $source = $query_rs->next)
  { $authentications->{$source->id} = $source;
  }

  my $id = $self->param("id");
  my $hostname = $self->param("hostname");
  my $authkey = $self->param("authkey");
  my $port = $self->param("port");  
  my $target = lc($self->param("target"));
  if ($valid_authentications{$target} && $authentications->{$id})
  { $authentications->{$id}->update({ hostname => $hostname, type => $target, authkey => $authkey, port => $port});
    $self->redirect_to("/authentication/");
  }
}

sub delete { # DELETE /authentication/123 - delete a authentication 
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $rs = $self->db->resultset('Authentication');
  my $query_rs = $rs->search();
  my $authentications = {};
  while (my $source = $query_rs->next)
  { $authentications->{$source->id} = $source;
  }

  my $id = $self->param("id");
  if ($authentications->{$id})
  { $authentications->{$id}->delete;
    delete($authentications->{$id});
  }
  $self->redirect_to("/authentication/");
}

1;
