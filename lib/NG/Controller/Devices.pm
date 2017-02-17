package NG::Controller::Devices;
use Mojo::Base 'Mojolicious::Controller';

my $devices = {};
for (1..100)
{ $devices->{"$_"} = { hostname => "Router $_", ipaddress => "10.0.0.$_", id => "$_" };
  $devices->{$_}{"acs"} = $_ % 2;
  $devices->{$_}{"ise"} = $_ % 2 ? 0 : 1;
}

     my $items = { "acs" => "ACS",
                   "ise" => "ISE",
                   "intermapper" => "Intermapper",
                   #"hpna" => "HP NA",
                   #"cacti" => "Cacti",
                   #"ldap" => "LDAP",
                   #"ad" => "AD",
                   #"nagios" => "Nagios",
                };

sub new_form { # GET /devices/new - form to create a device   
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  $self->render('devices/create', layout => 'accounts');
}

# This action will render a template
sub show { # GET /devices/123 - show device with id 123
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");
  my $device = $devices->{$id};
  $self->stash(device => $device);
  $self->render('devices/detail', layout => 'devices');
}

sub edit_form { # GET /devices/123/edit - form to update a device
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");  
}

# This action will render a template
sub index { # GET /devices - list of all devices
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $filter = $self->param('filter');
  my %devices = %{ $devices };
  for my $device (keys %devices)
  { for my $key (qw(acs ise ad intermapper)) #ldap nagios hpna intermapper cacti))
    { $devices->{$device}{$key} = ($devices->{$device}{$key} && $devices->{$device}{$key} ne "fa-close text-danger") ? "fa-check text-success" : "fa-close text-danger"; 
    }
  }
  $self->stash(devices => $devices);
  my $filterheader = "";
  if ($filter)
  { my %devices = %{ $devices };
    my @keys = grep { $devices->{$_}{$filter} ne "fa-close text-danger" } keys %devices;
    my %filterdevices = ();
    @filterdevices{@keys} = @devices{@keys};
    $self->stash(devices => \%filterdevices);
    $filterheader = "$items->{$filter} Devices - ";
  } else
  {  $self->stash(devices => $devices); }
  $self->stash(items => $items);
  $self->stash(filterheader => $filterheader);  
  $self->render('devices/index', layout => 'devices');
}

sub create { # POST /devices - create new account
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $hostname = $self->param("hostname");
  my $description = $self->param("description");
  my $ipaddress = $self->param("ipaddress");
  my %devices = %{ $devices };
  my @ids = sort { $a <=> $b } keys %devices;
  my $maxid = pop @ids;
  $maxid++;
  $devices->{$maxid}{"hostname"} = $hostname;
  $devices->{$maxid}{"description"} = $description;
  $devices->{$maxid}{"ipaddress"} = $ipaddress;
  $devices->{$maxid}{"id"} = $maxid;
  $self->redirect_to("/devices/$maxid");
}

sub update { # PUT /devices/123 - update a device
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");
  my $hostname = $self->param("hostname");
  my $description = $self->param("description");
  my $ipaddress = $self->param("ipaddress");
  $devices->{$id}{"hostname"} = $hostname;
  $devices->{$id}{"description"} = $description;
  $devices->{$id}{"ipaddress"} = $ipaddress;
  $self->redirect_to("/devices/");
}

sub delete { # DELETE /devices/123 - delete a device
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");    
  delete($devices->{$id});
  $self->redirect_to("/devices/");
}

1;
