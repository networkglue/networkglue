package NG::Controller::Login;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;
use Authen::TacacsPlus;
use Authen::Radius;

use MIME::Base64;

# This action will render a template
sub index
{ my $self = shift;
  &init($self);
}

sub init
{ my ($self) = @_;
  my $username = $self->param('username');
  my $password = $self->param('password');

  my $account_rs = $self->db->resultset('Account');
  my $query_rs = $account_rs->search();
  my $user = $query_rs->first;
  if (!$user)
  { if ($username && $password)
    { $self->db->resultset('Account')->create({
            name => $username,
            password => $password,
            authentication => 0,
            id => 1
        });
      &index($self);
    } else
    { $self->render('main/init');
    }
  } else
  { &on_user_login($self);
  } 
}

sub user_exists
{ my ($self, $username, $password) = @_;
  
  # This will only update Accounts table and not ACS, ISE or IM tables
  my $account_rs = $self->db->resultset('Account');
  my $query_rs = $account_rs->search({ name => $username});
  my $user = $query_rs->first;
  
  if ($user && $user->authentication == 0)
  { if (length($user->password) > 64) # Expect a user password not to be longer than 64 characters!?!? 
    { my $decpassword = $self->cipher->decrypt(decode_base64($user->password));
      if ($self->salt.$password.$username eq $decpassword)
      { return 1; } else
      { return 0; }
    }
    else
    { if ($password eq $user->password)
      { my $encpassword = encode_base64($self->cipher->encrypt($self->salt.$password.$username));
        $query_rs->update( { password => $encpassword} );
        $user = $query_rs->first;
        
        return 1;
      } else
      { return 0; }
    }
  } 
  if ($user && $user->authentication != 0)
  { my $auth_rs = $self->db->resultset('Authentication');
    my $query_rs = $auth_rs->search({ id => $user->authentication});
    my $auth = $query_rs->first;
    if ($auth->type eq "tacacs")
    { my $tac = Authen::TacacsPlus->new(Host=> $auth->hostname,
                        Key=>$auth->authkey,
                        [Port=>$auth->port],
                        [Timeout=>15]);
      my $result = $tac->authen($username, $password);
      return $result;
    }
    if ($auth->type eq "radius")
    { my $hostname = $auth->hostname;
      $hostname = $auth->port ? "$hostname:".$auth->port : $hostname;
      my $radius = Authen::Radius->new(Host => $hostname, Secret => $auth->authkey);
      my $result = $radius->check_pwd($username, $password);
      return $result;
    }
    return 0;
  }
  return 0;
}

sub on_user_login
{ my $self = shift;
  # Grab the request parameters
  my $username = $self->param('username');
  my $password = $self->param('password');
  my $status = user_exists($self, $username, $password);
  if ($username && $password)
  { if ($status)
    { $self->session(logged_in => 1);
      $self->session(username => $username);
      $self->redirect_to('/accounts/');
    } else
    { #$self->render(text => 'Wrong username/password', status => 403); # Provide template here!!
      my $message = qq(<div class="alert alert-danger">Wrong username or password!</div>);
      $self->stash(message => $message);
      $self->render('login/index');
    }
  } else
  { $self->stash(message => "");
    $self->render('login/index');
  }
}

sub logout
{ my $self = shift;
  $self->session(expires => 1);
  $self->redirect_to('/login/');
}

1;
