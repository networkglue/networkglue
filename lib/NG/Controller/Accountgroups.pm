package NG::Controller::Accountgroups;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;
use Net::Cisco::ACS::User;
use Net::Cisco::ISE::InternalUser;
use Net::Intermapper::User;

my $items = { "acs" => "ACS",
              "ise" => "ISE",
              "intermapper" => "Intermapper",
             };

my $accountgroups = {};
my $acsaccountgroups = {};
my $iseaccountgroups = {};
my $intermapperaccountgroups = {};

my $status_clean = 0;
my $status_changed = 1;
my $status_created = 2;

# Accountgroup deleting?? Delete from DB within app or within minion??

sub new_form { # GET /accountgroups/new - form to create an accountgroup
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');  
  my $filter = "";
  $self->stash(filter => $filter);
  $self->stash(items => $items);  
  my $username = $self->session('username');
  $self->stash(username => $username);

  $self->render('accountgroups/create', layout => 'accountgroups');
}

# This action will render a template
sub show { # GET /accountgroups/123 - show account group with id 123
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");
  my $filter = $self->param('filter');
  $self->consolidate() unless keys %{ $accountgroups };
  my $accountgroup = $accountgroups->{$id};
  $self->stash(accountgroup => $accountgroup);
  my $filterheader = "";

  my $acs_toggle = $accountgroup->{"acs"} && $accountgroup->{"acs"} ne "fa-close text-danger" ? " checked" : "";
  my $ise_toggle = $accountgroup->{"ise"} && $accountgroup->{"ise"} ne "fa-close text-danger" ? " checked" : "";
  my $im_toggle = $accountgroup->{"intermapper"} && $accountgroup->{"intermapper"} ne "fa-close text-danger" ? " checked" : "";

  $self->stash(acs_toggle => $acs_toggle);
  $self->stash(ise_toggle => $ise_toggle);
  $self->stash(im_toggle => $im_toggle);
  my $username = $self->session('username');
  $self->stash(username => $username);

  $self->stash(items => $items);
  $self->stash(filterheader => $filterheader);
  $filter = "?filter=$filter" if $filter;
  $self->stash(filter => $filter);

  $self->render('accountgroups/detail', layout => 'accountgroups');
}

sub edit_form { # GET /accountgroups/123/edit - form to update an accountgroup
}

sub index { # GET /accountgroups - list of all accountgroups
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');  
  $self->consolidate();
  my $filter = $self->param('filter');
  my %accountgroups = %{ $accountgroups };
  for my $accountgroup (keys %accountgroups)
  { for my $key (qw(acs ise ad ldap nagios hpna intermapper cacti))
    { $accountgroups->{$accountgroup}{$key} = ($accountgroups->{$accountgroup}{$key} && $accountgroups->{$accountgroup}{$key} ne "fa-close text-danger") ? "fa-check text-success" : "fa-close text-danger"; 
    }
  }
  $self->stash(accountgroups => $accountgroups);
  my $filterheader = "";
  if ($filter)
  { my %accountgroups = %{ $accountgroups };
    my @keys = grep { $accountgroups->{$_}{$filter} ne "fa-close text-danger" } keys %accountgroups;
    my %filteraccountgroups = ();
    @filteraccountgroups{@keys} = @accountgroups{@keys};
    $self->stash(accountgroups => \%filteraccountgroups);
    $filterheader = "$items->{$filter} Account Group - ";
  } else
  {  $self->stash(accountgroups => $accountgroups); }
  my $username = $self->session('username');
  $self->stash(username => $username);

  $self->stash(items => $items);
  $self->stash(filterheader => $filterheader);
  $filter = "?filter=$filter" if $filter;
  $self->stash(filter => $filter);
  $self->render('accountgroups/index', layout => 'accountgroups');
}

sub create { # POST /accountgroups - create new account group
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');  
  my $name = $self->param("name");
  my $password = $self->param("password");
  $self->db->resultset('Accountgroup')->create({
            name => $name,
        });

  my $acs_rs = $self->db->resultset('DsAcsIdentitygroup');
  my $query_rs = $acs_rs->search({ name => "__default" });
  my $defaultacs = $query_rs->first;

  my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
  $query_rs = $intermapper_rs->search({ name => "__default" });
  my $defaultintermapper = $query_rs->first;

  my $ise_rs = $self->db->resultset('DsIseIdentitygroup');
  $query_rs = $ise_rs->search({ name => "__default" });
  my $defaultise = $query_rs->first;

  # Temporary fix
  my $acsmax = $self->db->resultset('DsAcsIdentitygroup')->get_column('Id');
  my $acsmaxid = $acsmax->max;
  $acsmaxid++;
  
  # Temporary fix
  my $isemax = $self->db->resultset('DsIseIdentitygroup')->get_column('Id');
  my $isemaxid = $isemax->max;
  $isemaxid++;

  # Temporary fix
  my $immax = $self->db->resultset('DsIntermapperUser')->get_column('Id');
  my $immaxid = $immax->max;
  $immaxid++;
  
  my $acs_toggle = $self->param("acs_toggle") || "0";
  my $im_toggle = $self->param("im_toggle") || "0";
          
  my $acs_description = $self->param("acs_description");
  if ($defaultacs)
  { $acs_description ||= $defaultacs->description;
  }
  
  if ($acs_toggle)
  { $self->db->resultset('DsAcsIdentitygroup')->create(
      { description => $acs_description, name => $name, id => $acsmaxid, status => $status_created,
      });
  }

# Create dummy users here for non-existing usergroups in Intermapper
  if ($im_toggle)
  { $self->db->resultset('DsIntermapperUser')->create(
    { groups => $name, 
      name => "_____dummyxxxxxx",
      id => $immaxid,
      status => $status_created,
    });
  }     
  $self->redirect_to("/accountgroups/");
}

sub update { # PUT /accountgroups/123 - update an account group
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');  
  my $id = $self->param("id");
  my $acs_id = $self->param("acs_id");

  my $name = $self->param("name");

  # Temporary fix
  my $acsmax = $self->db->resultset('DsAcsIdentitygroup')->get_column('Id');
  my $acsmaxid = $acsmax->max;
  $acsmaxid++;

  # Accounts table update is REQUIRED STILL!!
  # Temporary fix
  my $immax = $self->db->resultset('DsIntermapperUser')->get_column('Id');
  my $immaxid = $immax->max;
  $immaxid++;
  
  # Temporary fix
  my $isemax = $self->db->resultset('DsIseIdentitygroup')->get_column('Id');
  my $isemaxid = $isemax->max;
  $isemaxid++;  
  
  my $acs_description = $self->param("acs_description");

# Should be fixed!!!
#  my $result_rs = $self->db->resultset('Accountgroup');
#  my $query_rs = $result_rs->search({ id => $id });
#  $query_rs->first->update({ name => $name });
  
  my $acs_toggle = $self->param("acs_toggle") || "0";
  my $ise_toggle = $self->param("ise_toggle") || "0";
  my $im_toggle = $self->param("im_toggle") || "0";
  if ($acs_id && $acs_toggle)
  { $accountgroups->{$id}{"acs_description"} = $acs_description;

    my $acs_rs = $self->db->resultset('DsAcsIdentitygroup');
    my $query_rs = $acs_rs->search({ id => $acs_id });
    $query_rs->first->update({ description => $acs_description, name => $name, status => $status_created, });
  }
  if (!$acs_id && $acs_toggle)  
  { if ($acs_description)
    { $self->db->resultset('DsAcsIdentitygroup')->create(
      { description => $acs_description, name => $name, status => $status_changed, id => $acsmaxid });
        $accountgroups->{$id}{"acs_description"} = $acs_description;
        $accountgroups->{$id}{"acs"} = 1;
        $accountgroups->{$id}{"acs_id"} = $acsmaxid;
    }
  }
  
  if ($acs_id && !$acs_toggle)  
  { my $acs_rs = $self->db->resultset('DsAcsIdentitygroup');
    my $query_rs = $acs_rs->search({ id => $acs_id });
    $query_rs->delete;
    delete($acsaccountgroups->{$id});
    $accountgroups->{$id}{"acs"} = 0;
  }

  my $ise_id = $self->param("ise_id");
  my $ise_description = $self->param("ise_description"); 

  if ($ise_id && $ise_toggle)
  { $accountgroups->{$id}{"ise_description"} = $ise_description;

    my $ise_rs = $self->db->resultset('DsIseIdentitygroup');
    my $query_rs = $ise_rs->search({ id => $ise_id });
    $query_rs->first->update({ description => $ise_description. name => $name });
  }
  if (!$ise_id && $ise_toggle)
  { if ($ise_description)
   { $self->db->resultset('DsIseIdentitygroup')->create(
        { description => $ise_description, name => $name });    
   }
  }

  if ($ise_id && !$ise_toggle)  
  { my $ise_rs = $self->db->resultset('DsIseIdentitygroup');
    my $query_rs = $ise_rs->search({ id => $ise_id });
    $query_rs->delete;
    delete($iseaccountgroups->{$id});
    $accountgroups->{$id}{"ise"} = 0;
  }
    
  my $intermapper_id = $self->param("intermapper_id");
  
  if ($intermapper_id && $im_toggle)
  { my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
    $self->app->log->debug("Update $intermapper_id - $im_toggle");
    my $query_rs = $intermapper_rs->search();
    #my %groups = ();
    while (my $accountgroup = $query_rs->next)
    { my @groups = split(/\,/,$accountgroup);
      #for my $group (@groups)
      #{ $groups{$group}++;
      #}
      # TODO: Map users to ALL groups - array ref mapped to user ID
    }
  }
  
  # This part needs to be tweaked to work with groups being embedded IN user groups
  # No IM group exists, needs to be created.
  if (!$intermapper_id && $im_toggle)  
  {  $self->db->resultset('DsIntermapperUser')->create(
    { id => $immaxid , groups => $name, external => "false", guest => "false",
      name => "_____dummy".(int(rand(999999))), password => "randomizedstring",
      status => $status_created
      # TODO: CLEANUP!
    });
    #$self->app->log->debug("Create $intermapper_id - $im_toggle");
  }
  
  # IM group exists, has to be deleted
  if ($intermapper_id && !$im_toggle)  
  { my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
    my $query_rs = $intermapper_rs->search();
    while (my $accountgroup = $query_rs->next)
    { my @groups = split(/\,/,$accountgroup->groups);
      for my $i (0..$#groups)
      { if ($groups[$i] eq $name)
        { delete($groups[$i]);
          my $groups = join(",",@groups);
          $query_rs->update({ groups => $groups });
        }
      }
    }
    delete($intermapperaccountgroups->{$id});
    $accountgroups->{$id}{"intermapper"} = 0;
    #$self->app->log->debug("Delete $intermapper_id - $im_toggle");    
  }

  $self->consolidate();
  
  $accountgroups->{$id}{"name"} = $name;
  $self->redirect_to("/accountgroups/$id");
}

sub delete { # DELETE /accountgroups/123 - delete a account group
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');  
  my $id = $self->param("id");
  my @extraid = @ { $self->every_param("extraid") };
  unshift(@extraid, $id);
  for my $id (@extraid)
  { delete($accountgroups->{$id});
    my $accountgroup_rs = $self->db->resultset('Accountgroup');
    my $query_rs = $accountgroup_rs->search({ name => $id });
    if ($query_rs)
    { $query_rs->delete;
    }
    
    my $ise_rs = $self->db->resultset('DsIseIdentitygroup');
    $query_rs = $ise_rs->search({ name => $id });
    if ($query_rs)
    { $query_rs->delete;
    }
    delete($iseaccountgroups->{$id});
      
    my $acs_rs = $self->db->resultset('DsAcsIdentitygroup');
    $query_rs = $acs_rs->search({ name => $id });
    if ($query_rs)
    { $query_rs->delete;
    }
    delete($acsaccountgroups->{$id});    
  }
  $self->redirect_to("/accountgroups/");
}

sub consolidate {
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my %datasources = $self->datasources;
  my $acs = $datasources{"acs"};
  my $intermapper = $datasources{"intermapper"};
  $accountgroups = {};

  my $accountgroup_rs = $self->db->resultset('Accountgroup');
  my $query_rs = $accountgroup_rs->search;
  while (my $accountgroup = $query_rs->next)
  { $accountgroups->{$accountgroup->name}{"name"} = $accountgroup->name if $accountgroup->name;
  }
  
  my $acs_rs = $self->db->resultset('DsAcsIdentitygroup');
  $query_rs = $acs_rs->search;
  while (my $accountgroup = $query_rs->next)
  { $acsaccountgroups->{$accountgroup->name} = $accountgroup if $accountgroup->name;
  }
  
  my $ise_rs = $self->db->resultset('DsIseIdentitygroup');
  $query_rs = $ise_rs->search;
  while (my $accountgroup = $query_rs->next)
  { $iseaccountgroups->{$accountgroup->name} = $accountgroup if $accountgroup->name; 
  }

  my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
  $query_rs = $intermapper_rs->search;
  while (my $accountgroup = $query_rs->next)
  { $intermapperaccountgroups->{$accountgroup->groups} = $accountgroup if $accountgroup->groups;
  }

  my %acs = ();
  my %intermapper = ();
  for my $db ($acsaccountgroups,$iseaccountgroups, $intermapperaccountgroups)
  { for my $key (keys %{$db})
    { if (ref($db->{$key}) eq "NG::Schema::Result::DsAcsIdentitygroup")
      { if (!$accountgroups->{$db->{$key}->name}{"name"})
        { $accountgroups->{$db->{$key}->name}{"name"} = $db->{$key}->name;
          $accountgroups->{$db->{$key}->name}{"description"} = $db->{$key}->description || "";
        }
        $accountgroups->{$db->{$key}->name}{"description"} ||= "";
        
        $accountgroups->{$db->{$key}->name}{"acs"} = 1;
        $accountgroups->{$db->{$key}->name}{"acs_description"} = $db->{$key}->description;
        $accountgroups->{$db->{$key}->name}{"acs_id"} = $db->{$key}->id;
        
        my $acs_identitygroup = Net::Cisco::ACS::IdentityGroup->new("name"=>$db->{$key}->name,
                                                  "description"=>$accountgroups->{$db->{$key}->name}{"acs_description"});
        $acs{$db->{$key}->name}  = $acs_identitygroup;
      }
      if (ref($db->{$key}) eq "NG::Schema::Result::DsIntermapperUser")
      { my @groups = split(/\,/,$db->{$key}->groups);
        for my $group (@groups)
        { if (!$accountgroups->{$group}{"name"})
          { $accountgroups->{$group}{"name"} = $group;
          }
          $accountgroups->{$group}{"intermapper"} = 1;
          $accountgroups->{$group}{"intermapper_id"} = $group;
        }

        #my $intermapper_user = Net::Intermapper::User->new("Name"=>"_____dummy",
        #                                                   "Groups"=>$accountgroups->{$db->{$key}->name}{"intermapper_groups"});
        #$intermapper{$db->{$key}->groups}  = $intermapper_user;
      }

      if (ref($db->{$key}) eq "NG::Schema::Result::DsIseIdentitygroup")
      { if (!$accountgroups->{$db->{$key}->name}{"name"})
        { $accountgroups->{$db->{$key}->name}{"name"} = $db->{$key}->name;
          $accountgroups->{$db->{$key}->name}{"description"} = $db->{$key}->description || "";
        }
        
        $accountgroups->{$db->{$key}->name}{"description"} ||= "";
        
        $accountgroups->{$db->{$key}->name}{"ise"} = 1;
        $accountgroups->{$db->{$key}->name}{"ise_id"} = $db->{$key}->id;
      }
      $acs->users(users => \%acs);
      $intermapper->users(\%intermapper);
    }
  }
  #$self->app->log->debug(Dumper \$accounts);
}

sub bool
{ return " checked" if $_[0];
}

1;
