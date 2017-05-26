package NG::Controller::Accountgroups;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;
use Net::Cisco::ACS::User;
use Net::Cisco::ISE::InternalUser;
use Net::Intermapper::User;
use Net::HP::NA::User;

my $accountgroups = {};
my $acsaccountgroups = {};
my $iseaccountgroups = {};
my $intermapperaccountgroups = {};
my $naaccountgroups = {};

my $status_clean = 0;
my $status_changed = 1;
my $status_created = 2;

# Accountgroup deleting?? Delete from DB within app or within minion??

sub new_form { # GET /accountgroups/new - form to create an accountgroup
  my $self = shift;
  $self->redirect_to('/login/') && return if !$self->session('logged_in');  
  my $filter = "";
  $self->stash(filter => $filter);
  $self->stash(items => $self->items);  
  my $username = $self->session('username');
  $self->stash(username => $username);
  
  my %acs_toggle = ();
  my %ise_toggle = ();
  my %im_toggle = ();
  my %na_toggle = ();
  
  my $sources_rs = $self->db->resultset('DsSource');
  my $query_rs = $sources_rs->search;
  my %sources = ();

  while (my $source = $query_rs->next)
  { $sources{$source->id} = $source;
  }

  my $accountgroup = {};  
  for my $source (keys %sources)
  { $accountgroup->{"stub_ise"}{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "ISE";
    $accountgroup->{"stub_acs"}{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "ACS";
    $accountgroup->{"stub_intermapper"}{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "Intermapper";
	$accountgroup->{"stub_na"}{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "NA";
  }

  $self->stash(accountgroup => $accountgroup);
  
  $self->stash(acs_toggle => \%acs_toggle);
  $self->stash(ise_toggle => \%ise_toggle);
  $self->stash(im_toggle => \%im_toggle);
  $self->stash(na_toggle => \%na_toggle);
  $self->stash(username => $username);

  $self->render('accountgroups/create', layout => 'accountgroups');
}

# This action will render a template
sub show { # GET /accountgroups/123 - show account group with id 123
  my $self = shift;
  $self->redirect_to('/login/') && return if !$self->session('logged_in');
  my $id = $self->param("id");
  my $filter = lc($self->param("filter"));
  $self->consolidate() unless keys %{ $accountgroups };
  my $accountgroup = $accountgroups->{$id};
  
  $self->stash(accountgroup => $accountgroup);
  my $filterheader = "";

  my $sources_rs = $self->db->resultset('DsSource');
  my $query_rs = $sources_rs->search;
  my $sources = {};
  my %acs_toggle = ();
  my %ise_toggle = ();
  my %im_toggle = ();
  my %na_toggle = ();
  
  while (my $source = $query_rs->next)
  { $sources->{$source->id} = $source->type->shortname;
  }

  for my $target (sort keys %{$sources})
  { if ($sources->{$target} eq "ACS")
    { $acs_toggle{$target} = $accountgroup->{"acs"} && $accountgroup->{"acs"} ne "fa-close text-danger" ? " checked" : "";
    }
    if ($sources->{$target} eq "ISE")
    { $ise_toggle{$target} = $accountgroup->{"ise"} && $accountgroup->{"ise"} ne "fa-close text-danger" ? " checked" : "";
    }
    
    if ($sources->{$target} eq "Intermapper")
    { $im_toggle{$target} = $accountgroup->{"intermapper"} && $accountgroup->{"intermapper"} ne "fa-close text-danger" ? " checked" : "";
    }
    if ($sources->{$target} eq "NA")
    { $na_toggle{$target} = $accountgroup->{"na"} && $accountgroup->{"na"} ne "fa-close text-danger" ? " checked" : "";
    }
  }

  $self->stash(acs_toggle => \%acs_toggle);
  $self->stash(ise_toggle => \%ise_toggle);
  $self->stash(im_toggle => \%im_toggle);
  $self->stash(na_toggle => \%na_toggle);
  my $username = $self->session('username');
  $self->stash(username => $username);
  $self->stash(items => $self->items);
  $self->stash(filterheader => $filterheader);
  $filter = "?filter=$filter" if $filter;
  $self->stash(filter => $filter);

  $self->render('accountgroups/detail', layout => 'accountgroups');
}

sub edit_form { # GET /accountgroups/123/edit - form to update an accountgroup
}

sub index { # GET /accountgroups - list of all accountgroups
  my $self = shift;
  $self->redirect_to('/login/') && return if !$self->session('logged_in');  
  $self->consolidate();
  my $filter = lc($self->param("filter"));
  my %accountgroups = %{ $accountgroups };
  my %status = ();
  for my $accountgroup (keys %accountgroups)
  { #for my $key (qw(acs ise ad ldap nagios hpna intermapper cacti))
    for my $key (qw(acs ise intermapper na))
    { #$accountgroups->{$accountgroup}{$key} = ($accountgroups->{$accountgroup}{$key} && $accountgroups->{$accountgroup}{$key} ne "fa-close text-danger") ? "fa-check text-success" : "fa-close text-danger"; 
	  $status{$accountgroup}{$key} = ($accountgroups->{$accountgroup}{$key} && $accountgroups->{$accountgroup}{$key} ne "fa-close text-danger") ? "fa-check text-success" : "fa-close text-danger"; 
    }
  }
  $self->stash(accountgroups => $accountgroups);
  $self->stash(status => \%status);
  my $filterheader = "";
  if ($filter)
  { my %accountgroups = %{ $accountgroups };
    my @keys = grep { $status{$_}{$filter} ne "fa-close text-danger" } keys %accountgroups;
    my %filteraccountgroups = ();
    @filteraccountgroups{@keys} = @accountgroups{@keys};
    $self->stash(accountgroups => \%filteraccountgroups);
    $filterheader = $self->items->{$filter}->type->shortname ." Account Group - " if $self->items->{$filter};
  } else
  {  $self->stash(accountgroups => $accountgroups); }
  my $username = $self->session('username');
  $self->stash(username => $username);

  $self->stash(items => $self->items);
  $self->stash(filterheader => $filterheader);
  $filter = "?filter=$filter" if $filter;
  $self->stash(filter => $filter);
  $self->render('accountgroups/index', layout => 'accountgroups');
}

sub create { # POST /accountgroups - create new account group
  my $self = shift;
  $self->redirect_to('/login/') && return if !$self->session('logged_in');  
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

  my $na_rs = $self->db->resultset('DsNaGroup');
  $query_rs = $na_rs->search({ usergroupname => "__default" });
  my $defaultna = $query_rs->first;
  
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

  # Temporary fix
  my $namax = $self->db->resultset('DsNaGroup')->get_column('usergroupid');
  my $namaxid = $namax->max;
  $namaxid++;
  
  my $acs_toggle = $self->param("acs_toggle") || "0";
  my $im_toggle = $self->param("im_toggle") || "0";
  my $ise_toggle = $self->param("ise_toggle") || "0";
  my $na_toggle = $self->param("na_toggle") || "0";
          
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
  $self->redirect_to('/login/') && return if !$self->session('logged_in');  
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
    my $query_rs = $intermapper_rs->search();
    #my %groups = ();
    while (my $accountgroup = $query_rs->next)
    { my (@groups) = split(/\,/,$accountgroup);
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
  }
  
  # IM group exists, has to be deleted
  if ($intermapper_id && !$im_toggle)  
  { my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
    my $query_rs = $intermapper_rs->search();
    while (my $accountgroup = $query_rs->next)
    { my (@groups) = split(/\,/,$accountgroup->groups);
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
  }

  $self->consolidate();
  
  $accountgroups->{$id}{"name"} = $name;
  $self->redirect_to("/accountgroups/$id");
}

sub delete { # DELETE /accountgroups/123 - delete a account group
  my $self = shift;
  $self->redirect_to('/login/') && return if !$self->session('logged_in');  
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
  $self->redirect_to('/login/') && return if !$self->session('logged_in');
  my $sources_rs = $self->db->resultset('DsSource');
  my $query_rs = $sources_rs->search;
  my %sources = ();
  $accountgroups = {};  

  while (my $source = $query_rs->next)
  { $sources{$source->id} = $source; }

  my $accountgroup_rs = $self->db->resultset('Accountgroup');
  $query_rs = $accountgroup_rs->search;
  while (my $accountgroup = $query_rs->next)
  { $accountgroups->{$accountgroup->name}{"name"} = $accountgroup->name if $accountgroup->name;
  }
  
  my $acs_rs = $self->db->resultset('DsAcsIdentitygroup');
  $query_rs = $acs_rs->search;
  while (my $accountgroup = $query_rs->next)
  { $acsaccountgroups->{$accountgroup->name}{$accountgroup->uid} = $accountgroup if $accountgroup->name;
    for my $source (keys %sources)
    { $accountgroups->{$accountgroup->name}{"stub_ise"}{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "ISE";
      $accountgroups->{$accountgroup->name}{"stub_intermapper" }{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "Intermapper";
	  $accountgroups->{$accountgroup->name}{"stub_na" }{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "NA";
    }
  }
  
  my $ise_rs = $self->db->resultset('DsIseIdentitygroup');
  $query_rs = $ise_rs->search;
  while (my $accountgroup = $query_rs->next)
  { $iseaccountgroups->{$accountgroup->name}{$accountgroup->uid} = $accountgroup if $accountgroup->name;
    for my $source (keys %sources)
    { $accountgroups->{$accountgroup->name}{"stub_acs"}{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "ACS";
      $accountgroups->{$accountgroup->name}{"stub_intermapper" }{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "Intermapper";
	  $accountgroups->{$accountgroup->name}{"stub_na" }{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "NA";
    }
  }

  my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
  $query_rs = $intermapper_rs->search;
  while (my $accountgroup = $query_rs->next)
  { my (@groups) = split(/\,/,$accountgroup->groups) if $accountgroup->groups;
    for my $group (@groups)
	{ $group =~ s/^\s*//g;
	  $group =~ s/\s*$//g;
	  my $altgroup = $group;
	  $altgroup =~ s/\s/_/g;
	  $intermapperaccountgroups->{$group}{$accountgroup->source->id."-".$altgroup} = $accountgroup;
      for my $source (keys %sources)
      { $accountgroups->{$group}{"stub_ise"}{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "ISE";
        $accountgroups->{$group}{"stub_acs"}{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "ACS";
	    $accountgroups->{$group}{"stub_na" }{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "NA";
      }
	}
  }

  my $na_rs = $self->db->resultset('DsNaGroup');
  $query_rs = $na_rs->search;
  while (my $accountgroup = $query_rs->next)
  { $naaccountgroups->{$accountgroup->username}{$accountgroup->uid} = $accountgroup if $accountgroup->username;
    for my $source (keys %sources)
    { $accountgroups->{$accountgroup->name}{"stub_ise"}{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "ISE";
      $accountgroups->{$accountgroup->name}{"stub_acs"}{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "ACS";
      $accountgroups->{$accountgroup->name}{"stub_intermapper"}{$sources{$source}->id."-X"}{"source"} = $sources{$source} if $sources{$source}->type->shortname eq "Intermapper";
    }
  }
  my %acs = ();
  my %intermapper = ();
  my %ise = ();
  my %na = ();
  for my $db ($acsaccountgroups,$iseaccountgroups, $intermapperaccountgroups,$naaccountgroups)
  { for my $key (keys %{$db})
    { for my $uid (keys %{$db->{$key}}) # UIDs = Users
      { if (ref($db->{$key}{$uid}) eq "NG::Schema::Result::DsAcsIdentitygroup")
		{ #if (!$accountgroups->{$db->{$key}{$uid}->name}{"name"})
		  { $accountgroups->{$db->{$key}{$uid}->name}{"name"} = $db->{$key}{$uid}->name;
		    $accountgroups->{$db->{$key}{$uid}->name}{"description"} = $db->{$key}{$uid}->description || "";
		  }
		  delete($accountgroups->{$db->{$key}{$uid}->name}{"stub_acs"}{$db->{$key}{$uid}->source->id."-X"});
          $accountgroups->{$db->{$key}{$uid}->name}{"description"} ||= $db->{$key}{$uid}->description;
          $accountgroups->{$db->{$key}{$uid}->name}{"acs"}{$uid}{"id"} = $db->{$key}{$uid}->id;
          $accountgroups->{$db->{$key}{$uid}->name}{"acs"}{$uid}{"uid"} = $db->{$key}{$uid}->uid;
          $accountgroups->{$db->{$key}{$uid}->name}{"acs"}{$uid}{"source"} = $db->{$key}{$uid}->source;
          $acs{$db->{$key}{$uid}->name}  = 1;
          #my $acs_identitygroup = Net::Cisco::ACS::IdentityGroup->new("name"=>$db->{$key}{$uid}->name,
          #                                        "description"=>$accountgroups->{$db->{$key}{$uid}->name}{"acs_description"});
          #$acs{$db->{$key}{$uid}->name}  = $acs_identitygroup;
		}
		if (ref($db->{$key}{$uid}) eq "NG::Schema::Result::DsIntermapperUser")
		{ my (@groups) = split(/\,/,$db->{$key}{$uid}->groups);
		  for my $group (@groups)
          { #if (!$accountgroups->{$group}{"name"})
		    $group =~ s/^\s*//g;
			$group =~ s/\s*$//g;
		    if ($group)
            { $accountgroups->{$group}{"name"} = $group;
              delete($accountgroups->{$group}{"stub_intermapper"}{$db->{$key}{$uid}->source->id."-X"});
              $accountgroups->{$group}{"intermapper"}{$uid}{"name"} = $group;
              $accountgroups->{$group}{"intermapper"}{$uid}{"uid"} = $uid;
              $accountgroups->{$group}{"intermapper"}{$uid}{"id"} = $db->{$key}{$uid}->id;
              $accountgroups->{$group}{"intermapper"}{$uid}{"source"} = $db->{$key}{$uid}->source;
			  $intermapper{$group} = 1;
			}
          }
          #my $intermapper_user = Net::Intermapper::User->new("Name"=>"_____dummy",
          #                                                   "Groups"=>$accountgroups->{$db->{$key}->name}{"intermapper_groups"});
          #$intermapper{$db->{$key}->groups}  = $intermapper_user;
        }
      
        if (ref($db->{$key}{$uid}) eq "NG::Schema::Result::DsIseIdentitygroup")
        { #if (!$accountgroups->{$db->{$key}{$uid}->name}{"name"})
          { $accountgroups->{$db->{$key}{$uid}->name}{"name"} = $db->{$key}{$uid}->name;
            $accountgroups->{$db->{$key}{$uid}->name}{"description"} = $db->{$key}{$uid}->description || "";
          }
	      delete($accountgroups->{$db->{$key}{$uid}->name}{"stub_ise"}{$db->{$key}{$uid}->source->id."-X"});
          $accountgroups->{$db->{$key}{$uid}->name}{"description"} ||= "";
          $accountgroups->{$db->{$key}{$uid}->name}{"ise"}{$uid}{"id"} = $db->{$key}{$uid}->id;
          $accountgroups->{$db->{$key}{$uid}->name}{"ise"}{$uid}{"uid"} = $db->{$key}{$uid}->uid;
          $accountgroups->{$db->{$key}{$uid}->name}{"ise"}{$uid}{"source"} = $db->{$key}{$uid}->source;
          $ise{$db->{$key}{$uid}->name} = 1;

        }
        if (ref($db->{$key}{$uid}) eq "NG::Schema::Result::DsNaGroup")
        { #if (!$accountgroups->{$db->{$key}{$uid}->name}{"name"})
          { $accountgroups->{$db->{$key}{$uid}->name}{"name"} = $db->{$key}{$uid}->name;
            $accountgroups->{$db->{$key}{$uid}->name}{"description"} = $db->{$key}{$uid}->description || "";
          }
		  delete($accountgroups->{$db->{$key}{$uid}->name}{"stub_na"}{$db->{$key}{$uid}->source->id."-X"});
          $accountgroups->{$db->{$key}{$uid}->name}{"na"}{$uid}{"id"} = $db->{$key}{$uid}->userid;
          $accountgroups->{$db->{$key}{$uid}->name}{"na"}{$uid}{"uid"} = $db->{$key}{$uid}->uid;
          $accountgroups->{$db->{$key}{$uid}->name}{"na"}{$uid}{"source"} = $db->{$key}{$uid}->source;
          $na{$db->{$key}{$uid}->name} = 1;
        }
	  }

      # TODO: FIX THIS AND USE SEPARATE UID TO IDENTIFY CORRECT DATA SOURCE
      for my $source (keys %sources)
      { if (ref($sources{$source}) eq "Net::Cisco::ACS")
        { #$acs->users(users => \%acs);
        }
        if (ref($sources{$source}) eq "Net::Cisco::ISE")
        { #$ise->internalusers(internalusers => \%ise);
        }
        if (ref($sources{$source}) eq "Net::Intermapper")
        { #$intermapper->users(\%intermapper);
        }
        if (ref($sources{$source}) eq "Net::HP::NA")
        { #$na->users(\%na);
        }
	  }
	}
  }
}

sub bool
{ return " checked" if $_[0];
}

1;
