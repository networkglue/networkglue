package NG::Controller::Accounts;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;
use Net::Cisco::ACS::User;
use Net::Cisco::ISE::InternalUser;
use Net::Intermapper::User;

use Digest::MD5 qw(md5_hex);
use MIME::Base64;

     my $items = { "acs" => "ACS",
                   "ise" => "ISE",
                   "intermapper" => "Intermapper",
                   #"hpna" => "HP NA",
                   #"cacti" => "Cacti",
                   #"ldap" => "LDAP",
                   #"ad" => "AD",
                   #"nagios" => "Nagios",
                };

my $accounts = {};
my $acsaccounts = {};
my $iseaccounts = {};
my $intermapperaccounts = {};

my $status_clean = 0;
my $status_changed = 1;
my $status_created = 2;

sub new_form { # GET /accounts/new - form to create a account   
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $filter = "";
  $self->stash(filter => $filter);
  $self->stash(items => $items);  

  my $acs_rs = $self->db->resultset('DsAcsIdentitygroup');
  my $query_rs = $acs_rs->search;
  my $acsidgroups = {};
  while (my $accountgroup = $query_rs->next)
  { $acsidgroups->{$accountgroup->id} = $accountgroup->name; }
  $self->stash(acsidgroups => $acsidgroups);

  my $ise_rs = $self->db->resultset('DsIseIdentitygroup');
  $query_rs = $ise_rs->search;
  my $iseidgroups = {};
  while (my $accountgroup = $query_rs->next)
  { $iseidgroups->{$accountgroup->id} = $accountgroup->name; }
  $self->stash(iseidgroups => $iseidgroups);

  my $im_rs = $self->db->resultset('DsIntermapperUser');
  $query_rs = $im_rs->search;
  my $imidgroups = {};
  while (my $accountgroup = $query_rs->next)
  { my (@groups) = split(/\,/,$accountgroup->groups);
    for my $name (@groups)
    { $imidgroups->{$name}{"name"} = $name;
    }
  } 
  $self->stash(imidgroups => $imidgroups);
 
  $self->render('accounts/create', layout => 'accounts');
}

# This action will render a template
sub show { # GET /accounts/123 - show account with id 123
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my $id = $self->param("id");
  my $filter = $self->param('filter');
  $self->consolidate() unless keys %{ $accounts };
  my $account = $accounts->{$id};
  $self->stash(account => $account);
  my $filterheader = "";
 
  my $acs_rs = $self->db->resultset('DsAcsIdentitygroup');
  my $query_rs = $acs_rs->search;
  my $acsidgroups = {};

  while (my $accountgroup = $query_rs->next)
  { $acsidgroups->{$accountgroup->id}{"name"} = $accountgroup->name;
    $acsidgroups->{$accountgroup->id}{"selected"} = " selected" if $account->{"acs_identitygroupname"} && $account->{"acs_identitygroupname"} eq $accountgroup->name;
  }
  $self->stash(acsidgroups => $acsidgroups);

  my $ise_rs = $self->db->resultset('DsIseIdentitygroup');
  $query_rs = $ise_rs->search;
  my $iseidgroups = {};

  while (my $accountgroup = $query_rs->next)
  { $iseidgroups->{$accountgroup->id}{"name"} = $accountgroup->name;
    $iseidgroups->{$accountgroup->id}{"selected"} = " selected" if $account->{"ise_identitygroups"} && $account->{"ise_identitygroups"} eq $accountgroup->id;
  }
  $self->stash(iseidgroups => $iseidgroups);

  my $im_rs = $self->db->resultset('DsIntermapperUser');
  $query_rs = $im_rs->search;
  my $imidgroups = {};

  while (my $accountgroup = $query_rs->next)
  { my (@groups) = split(/\,/,$accountgroup->groups);
    for my $name (@groups)
    { $imidgroups->{$name}{"name"} = $name;
      $imidgroups->{$name}{"selected"} = " selected" if $account->{"intermapper_groups"} && $account->{"intermapper_groups"} eq $name;
    }
  } 
  $self->stash(imidgroups => $imidgroups);
  
  my $acs_toggle = $account->{"acs"} && $account->{"acs"} ne "fa-close text-danger" ? " checked" : "";
  my $ise_toggle = $account->{"ise"} && $account->{"ise"} ne "fa-close text-danger" ? " checked" : "";
  my $im_toggle = $account->{"intermapper"} && $account->{"intermapper"} ne "fa-close text-danger" ? " checked" : "";

  $self->stash(acs_toggle => $acs_toggle);
  $self->stash(ise_toggle => $ise_toggle);
  $self->stash(im_toggle => $im_toggle);

  $self->stash(items => $items);
  $self->stash(filterheader => $filterheader);
  $filter = "?filter=$filter" if $filter;
  $self->stash(filter => $filter);
  $self->render('accounts/detail', layout => 'accounts');
}

sub edit_form { # GET /accounts/123/edit - form to update a account
}

# This action will render a template
sub index { # GET /accounts - list of all accounts
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  $self->consolidate();
  my $filter = $self->param('filter');
  my %accounts = %{ $accounts };
  for my $account (keys %accounts)
  { for my $key (qw(acs ise ad ldap nagios hpna intermapper cacti))
    { $accounts->{$account}{$key} = ($accounts->{$account}{$key} && $accounts->{$account}{$key} ne "fa-close text-danger") ? "fa-check text-success" : "fa-close text-danger"; 
    }
  }
  $self->stash(accounts => $accounts);
  my $filterheader = "";
  if ($filter)
  { my %accounts = %{ $accounts };
    my @keys = grep { $accounts->{$_}{$filter} ne "fa-close text-danger" } keys %accounts;
    my %filteraccounts = ();
    @filteraccounts{@keys} = @accounts{@keys};
    $self->stash(accounts => \%filteraccounts);
    $filterheader = "$items->{$filter} Accounts - ";
  } else
  {  $self->stash(accounts => $accounts); }
  $self->stash(items => $items);
  $self->stash(filterheader => $filterheader);
  $filter = "?filter=$filter" if $filter;
  $self->stash(filter => $filter);
  $self->render('accounts/index', layout => 'accounts');
}

sub create { # POST /accounts - create new account
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');  
  my $name = $self->param("name");
  my $password = $self->param("password");

  # Temporary fix
  my $amax = $self->db->resultset('Account')->get_column('Id');
  my $amaxid = $amax->max;
  $amaxid++;


  $self->db->resultset('Account')->create({
            name => $name,
            password => $password,
            id => $amaxid
        });

  my $acs_rs = $self->db->resultset('DsAcsUser');
  my $query_rs = $acs_rs->search({ name => "__default" });
  my $defaultacs = $query_rs->first;

  my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
  $query_rs = $intermapper_rs->search({ name => "__default" });
  my $defaultintermapper = $query_rs->first;

  my $ise_rs = $self->db->resultset('DsIseInternaluser');
  $query_rs = $ise_rs->search({ name => "__default" });
  my $defaultise = $query_rs->first;

  # Temporary fix
  my $immax = $self->db->resultset('DsIntermapperUser')->get_column('Id');
  my $immaxid = $immax->max;
  $immaxid++;
  
  # Temporary fix
  my $acsmax = $self->db->resultset('DsAcsUser')->get_column('Id');
  my $acsmaxid = $acsmax->max;
  $acsmaxid++;
  
  # Temporary fix
  my $isemax = $self->db->resultset('DsIseInternaluser')->get_column('Id');
  my $isemaxid = $isemax->max;
  $isemaxid++;

  my $acs_toggle = $self->param("acs_toggle") || "0";
  my $ise_toggle = $self->param("ise_toggle") || "0";
  my $im_toggle = $self->param("im_toggle") || "0";
  
  my $acs_enabled = $self->param("acs_enabled");
  my $acs_description = $self->param("acs_description");
  my $acs_identitygroupname = $self->param("acs_identitygroupname");
  my $acs_enablepassword = $self->param("acs_enablepassword");
  my $acs_passwordneverexpires = $self->param("acs_passwordneverexpires");
  my $acs_dateexceedsenabled = $self->param("acs_dateexceedsenabled");
  my $acs_dateexceeds = $self->param("acs_dateexceeds");
  my $acs_passwordtype = $self->param("acs_passwordtype");

  # Need to store full datetime instead of date
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  $mon++;
  $year += 1900;  
  my $created = "$mday/$mon/$year";
  my $lastmodified = "$mday/$mon/$year";
  
  if ($defaultacs)
  { $acs_enabled ||= $defaultacs->enabled;  
    $acs_description ||= $defaultacs->description;
    $acs_identitygroupname ||= $defaultacs->identitygroupname;
    $acs_enablepassword ||= $defaultacs->enablepassword;
    $acs_passwordneverexpires ||=  $defaultacs->passwordneverexpires;
    $acs_dateexceedsenabled ||= $defaultacs->dateexceedsenabled;
    $acs_dateexceeds ||=  $defaultacs->dateexceeds;
    $acs_passwordtype ||= $defaultacs->passwordtype;
  }

  if ($acs_toggle)
  { $self->db->resultset('DsAcsUser')->create(
      { enabled => $acs_enabled, description => $acs_description, identitygroupname => $acs_identitygroupname,
        enablepassword => $acs_enablepassword, passwordneverexpires => $acs_passwordneverexpires,
        dateexceedsenabled => $acs_dateexceedsenabled, dateexceeds => $acs_dateexceeds, passwordtype => $acs_passwordtype,
        name => $name, password => $password, id => $acsmaxid, status => $status_created,
      });
  }
  
  my $ise_enabled = $self->param("ise_enabled");
  my $ise_firstname = $self->param("ise_firstname");
  my $ise_lastname = $self->param("ise_lastname"); 
  my $ise_identitygroups = $self->param("ise_identitygroups");
  my $ise_email = $self->param("ise_email");
  my $ise_enablepassword = $self->param("ise_enablepassword");
  my $ise_changepassword = $self->param("ise_changepassword");
  my $ise_expirydateenabled = $self->param("ise_expirydateenabled");
  my $ise_expirydate = $self->param("ise_expirydate");
  my $ise_passwordidstore = $self->param("ise_passwordidstore");

  if ($defaultise) 
  { $ise_enabled ||= $defaultise->enabled;
    $ise_firstname ||= $defaultise->firstname;
    $ise_lastname ||= $defaultise->lastname; 
    $ise_identitygroups ||= $defaultise->identitygroups;
    $ise_email ||= $defaultise->email;  
    $ise_enablepassword ||= $defaultise->enablepassword;
    $ise_changepassword ||= $defaultise->changepassword;
    $ise_expirydateenabled ||= $defaultise->expirydateenabled;
    $ise_expirydate ||= $defaultise->expirydate;
    $ise_passwordidstore ||= $defaultise->passwordidstore;
  }
  
  if ($ise_toggle)
  {  $self->db->resultset('DsIseInternaluser')->create(
        { enabled => $ise_enabled, firstname => $ise_firstname, lastname => $ise_lastname,
          identitygroups => $ise_identitygroups, email => $ise_email, enablepassword => $ise_enablepassword,
          changepassword => $ise_changepassword, expirydateenabled => $ise_expirydateenabled, expirydate=> $ise_expirydate,
          passwordidstore => $ise_passwordidstore, name => $name, password => $password, id => $isemaxid, status => $status_created,
        });
  }
  
  my $intermapper_groups = $self->param("intermapper_groups");
  my $intermapper_guest = $self->param("intermapper_guest");
  my $intermapper_external = $self->param("intermapper_external");

  if ($defaultintermapper)
  { $intermapper_groups ||= $defaultintermapper->groups;
    $intermapper_guest ||= $defaultintermapper->guest;
    $intermapper_external ||= $defaultintermapper->external;
  }
  if ($im_toggle)
  {  $self->db->resultset('DsIntermapperUser')->create(
    { groups => $intermapper_groups, external => $intermapper_external, guest => $intermapper_guest,
      name => $name, password => $password, id => $immaxid, status => $status_created,
    });
  }
  
  $self->redirect_to("/accounts/");
}

sub update { # PUT /accounts/123 - update a account
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');  
  my $id = $self->param("id");
  my $acs_id = $self->param("acs_id");

  # Accounts table update is REQUIRED STILL!!
  # Temporary fix
  my $immax = $self->db->resultset('DsIntermapperUser')->get_column('Id');
  my $immaxid = $immax->max;
  $immaxid++;
  
  # Temporary fix
  my $isemax = $self->db->resultset('DsIseIdentitygroup')->get_column('Id');
  my $isemaxid = $isemax->max;
  $isemaxid++;  

  my $acs_toggle = $self->param("acs_toggle") || "0";
  my $ise_toggle = $self->param("ise_toggle") || "0";
  my $im_toggle = $self->param("im_toggle") || "0";
  
  my $name = $self->param("name");
  my $password = $self->param("password");
  my $encpassword = encode_base64($self->cipher->encrypt($self->salt.$password.$name));
  
  my $acs_enabled = $self->param("acs_enabled");  
  my $acs_description = $self->param("acs_description");
  my $acs_identitygroupname = $self->param("acs_identitygroupname");
  my $acs_enablepassword = $self->param("acs_enablepassword");
  my $acs_encenablepassword = encode_base64($self->cipher->encrypt($self->salt.$acs_enablepassword.$name));
  my $acs_passwordneverexpires = $self->param("acs_passwordneverexpires");
  my $acs_dateexceedsenabled = $self->param("acs_dateexceedsenabled");
  my $acs_dateexceeds = $self->param("acs_dateexceeds");
  my $acs_passwordtype = $self->param("acs_passwordtype");
  my $checksum = md5_hex($name.$encpassword.$acs_enabled.$acs_description.$acs_identitygroupname.$acs_enablepassword.$acs_passwordneverexpires.$acs_dateexceedsenabled.
                         $acs_dateexceeds.$acs_passwordtype);
  
  # Need to store full datetime instead of date
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  $mon++;
  $year += 1900;  
  my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec); 
  my $lastmodified = "$months[$mon] $mday $year $hour:$min:$sec";
  my $created = "$months[$mon] $mday $year $hour:$min:$sec";
  
  if ($acs_id && $acs_toggle)
  { $accounts->{$id}{"acs_enabled"} = $acs_enabled;
    $accounts->{$id}{"acs_description"} = $acs_description;
    $accounts->{$id}{"acs_identitygroupname"} = $acs_identitygroupname;
    $accounts->{$id}{"acs_enablepassword"} = $acs_encenablepassword;
    $accounts->{$id}{"acs_passwordneverexpires"} = $acs_passwordneverexpires;
    $accounts->{$id}{"acs_dateexceedsenabled"} = $acs_dateexceedsenabled;
    $accounts->{$id}{"acs_dateexceeds"} = $acs_dateexceeds;
    $accounts->{$id}{"acs_passwordtype"} = $acs_passwordtype;
    $accounts->{$id}{"acs_lastmodified"} = $lastmodified;
    $accounts->{$id}{"acs_password"} = $encpassword;
    
    my $acs_rs = $self->db->resultset('DsAcsUser');
    my $query_rs = $acs_rs->search({ id => $acs_id });
    $query_rs->first->update({ enabled => $acs_enabled, description => $acs_description, identitygroupname => $acs_identitygroupname,
                     enablepassword => $acs_encenablepassword, passwordneverexpires => $acs_passwordneverexpires,
                     dateexceedsenabled => $acs_dateexceedsenabled, dateexceeds => $acs_dateexceeds, passwordtype => $acs_passwordtype,
                     name => $name, password => $encpassword, status => $status_changed, lastmodified => $lastmodified, checksum => $checksum
                  });
  }
  if (!$acs_id && $acs_toggle)  
  { if ($acs_enabled || $acs_description || $acs_identitygroupname || $acs_encenablepassword || $acs_passwordneverexpires || $acs_dateexceedsenabled ||
        $acs_dateexceeds || $acs_passwordtype)
    { $self->db->resultset('DsAcsUser')->create(
      { enabled => $acs_enabled, description => $acs_description, identitygroupname => $acs_identitygroupname,
        enablepassword => $acs_encenablepassword, passwordneverexpires => $acs_passwordneverexpires,
        dateexceedsenabled => $acs_dateexceedsenabled, dateexceeds => $acs_dateexceeds, passwordtype => $acs_passwordtype, checksum => $checksum,
        name => $name, password => $encpassword, status => $status_created, id => $immaxid, lastmodified => $lastmodified, created => $created
      });
      $accounts->{$id}{"acs_created"} = $created;
    }
  }
  
  if ($acs_id && !$acs_toggle)  
  { my $acs_rs = $self->db->resultset('DsAcsUser');
    my $query_rs = $acs_rs->search({ id => $acs_id });
    $query_rs->delete;
    delete($acsaccounts->{$id});
    $accounts->{$id}{"acs"} = 0;
  }
  
  my $ise_id = $self->param("ise_id");
  my $ise_enabled = $self->param("ise_enabled");
  my $ise_firstname = $self->param("ise_firstname");
  my $ise_lastname = $self->param("ise_lastname"); 
  my $ise_identitygroups = $self->param("ise_identitygroups");
  my $ise_email = $self->param("ise_email");  
  my $ise_enablepassword = $self->param("ise_enablepassword");
  my $ise_encenablepassword = encode_base64($self->cipher->encrypt($self->salt.$ise_enablepassword.$name));
  my $ise_changepassword = $self->param("ise_changepassword");
  my $ise_expirydateenabled = $self->param("ise_expirydateenabled");
  my $ise_expirydate = $self->param("ise_expirydate");
  my $ise_passwordidstore = $self->param("ise_passwordidstore");
  $checksum = md5_hex($name.$encpassword.$ise_enabled.$ise_firstname.$ise_lastname.$ise_identitygroups.$ise_email.$ise_encenablepassword.
                      $ise_changepassword.$ise_expirydateenabled.$ise_expirydate.$ise_passwordidstore);

  if ($ise_id && $ise_toggle)
  { $accounts->{$id}{"ise_enabled"} = $ise_enabled;
    $accounts->{$id}{"ise_firstname"} = $ise_firstname;
    $accounts->{$id}{"ise_lasttname"} = $ise_lastname;    
    $accounts->{$id}{"ise_identitygroups"} = $ise_identitygroups;
    $accounts->{$id}{"ise_email"} = $ise_email;    
    $accounts->{$id}{"ise_enablepassword"} = $ise_encenablepassword;
    $accounts->{$id}{"ise_changepassword"} = $ise_changepassword;
    $accounts->{$id}{"ise_expirydateenabled"} = $ise_expirydateenabled;
    $accounts->{$id}{"ise_expirydate"} = $ise_expirydate;
    $accounts->{$id}{"ise_passwordidstore"} = $ise_passwordidstore;

    my $ise_rs = $self->db->resultset('DsIseInternaluser');
    my $query_rs = $ise_rs->search({ id => $ise_id });
    if ($query_rs)
    { $query_rs->first->update({ enabled => $ise_enabled, firstname => $ise_firstname, lastname => $ise_lastname,
                     identitygroups => $ise_identitygroups, email => $ise_email, enablepassword => $ise_encenablepassword,
                     changepassword => $ise_changepassword, expirydateenabled => $ise_expirydateenabled, expirydate=> $ise_expirydate,
                     passwordidstore => $ise_passwordidstore, name => $name, password => $encpassword, status => $status_changed, checksum => $checksum
                  });
    }
  }
  
  if (!$ise_id && $ise_toggle)
  { if ($ise_enabled || $ise_firstname || $ise_lastname || $ise_identitygroups || $ise_email || $ise_encenablepassword ||
        $ise_changepassword || $ise_expirydateenabled || $ise_expirydate || $ise_passwordidstore)
     { $self->db->resultset('DsIseInternaluser')->create(
        { enabled => $ise_enabled, firstname => $ise_firstname, lastname => $ise_lastname,
          identitygroups => $ise_identitygroups, email => $ise_email, enablepassword => $ise_encenablepassword,
          changepassword => $ise_changepassword, expirydateenabled => $ise_expirydateenabled, expirydate=> $ise_expirydate,
          passwordidstore => $ise_passwordidstore, name => $name, password => $encpassword, status => $status_created, id => $isemaxid, checksum => $checksum
        });    
     }
  }

  if ($ise_id && !$ise_toggle)  
  { my $ise_rs = $self->db->resultset('DsIseInternaluser');
    my $query_rs = $ise_rs->search({ id => $ise_id });
    $query_rs->delete;
    delete($iseaccounts->{$id});
    $accounts->{$id}{"ise"} = 0;
  }
  
  my $intermapper_id = $self->param("intermapper_id");
  my $intermapper_groups = $self->param("intermapper_groups");
  my $intermapper_guest = $self->param("intermapper_guest");
  my $intermapper_external = $self->param("intermapper_external");
  $checksum = md5_hex($name.$encpassword.$intermapper_groups.$intermapper_guest.$intermapper_external);

  if ($intermapper_id && $im_toggle)
  { $accounts->{$id}{"intermapper_groups"} = $intermapper_groups;
    $accounts->{$id}{"intermapper_guest"} = $intermapper_guest;
    $accounts->{$id}{"intermapper_external"} = $intermapper_external;

    my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
    my $query_rs = $intermapper_rs->search({ id => $intermapper_id });
    $query_rs->first->update({ groups => $intermapper_groups, external => $intermapper_external, guest => $intermapper_guest,
                    name => $name, password => $encpassword, status => $status_changed, checksum => $checksum
                  });
  }
  
  if (!$intermapper_id && $im_toggle)
  { if ($intermapper_groups || $intermapper_guest || $intermapper_external)
   {  $self->db->resultset('DsIntermapperUser')->create(
    { groups => $intermapper_groups, external => $intermapper_external, guest => $intermapper_guest,
      name => $name, password => $encpassword, status => $status_created, id => $immaxid, checksum => $checksum
    });
   }
  }
  
  if ($intermapper_id && !$im_toggle)  
  { my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
    my $query_rs = $intermapper_rs->search({ id => $intermapper_id });
    $query_rs->delete;
    delete($intermapperaccounts->{$id});
    $accounts->{$id}{"intermapper"} = 0;
  }
  
  $self->consolidate();
  
  $accounts->{$id}{"name"} = $name;
  $accounts->{$id}{"password"} = $encpassword;
  $self->redirect_to("/accounts/$id");
}

sub delete { # DELETE /accounts/123 - delete a account
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');  
  my $id = $self->param("id");
  my @extraid = @ { $self->every_param("extraid") };
  unshift(@extraid, $id);
  for my $id (@extraid)
  { delete($accounts->{$id});
    my $account_rs = $self->db->resultset('Account');
    my $query_rs = $account_rs->search({ name => $id });
    if ($query_rs)
    { $query_rs->delete;
    }
    
    my $ise_rs = $self->db->resultset('DsIseInternaluser');
    $query_rs = $ise_rs->search({ name => $id });
    if ($query_rs)
    { $query_rs->delete;
    }
    delete($iseaccounts->{$id});
      
    my $acs_rs = $self->db->resultset('DsAcsUser');
    $query_rs = $acs_rs->search({ name => $id });
    if ($query_rs)
    { $query_rs->delete;
    }
    delete($acsaccounts->{$id});
  
    my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
    $query_rs = $intermapper_rs->search({ name => $id });
    if ($query_rs)
    { $query_rs->delete;
    }
    delete($intermapperaccounts->{$id});    
  }
  $self->redirect_to("/accounts/");
}

sub consolidate {
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  my %datasources = $self->datasources;
  my $acs = $datasources{"acs"};
  my $intermapper = $datasources{"intermapper"};
  $accounts = {};

  my $account_rs = $self->db->resultset('Account');
  my $query_rs = $account_rs->search;
  while (my $account = $query_rs->next)
  { $accounts->{$account->name}{"name"} = $account->name if $account->name;
  }
  
  my $acs_rs = $self->db->resultset('DsAcsUser');
  $query_rs = $acs_rs->search;
  while (my $account = $query_rs->next)
  { $acsaccounts->{$account->name} = $account if $account->name;
  }
  
  my $ise_rs = $self->db->resultset('DsIseInternaluser');
  $query_rs = $ise_rs->search;
  while (my $account = $query_rs->next)
  { $iseaccounts->{$account->name} = $account if $account->name;
    if ($iseaccounts->{$account->name}->identitygroups ne '1')
    { #$self->app->log->debug(Dumper $iseaccounts->{$account->name}->identitygroups);
    }
  }

  my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
  $query_rs = $intermapper_rs->search;
  while (my $account = $query_rs->next)
  { $intermapperaccounts->{$account->name} = $account if $account->name;
  }

  my %acs = ();
  my %intermapper = ();
  for my $db ($acsaccounts,$iseaccounts, $intermapperaccounts)
  { for my $key (keys %{$db})
    { if (ref($db->{$key}) eq "NG::Schema::Result::DsAcsUser")
      { if (!$accounts->{$db->{$key}->name}{"name"})
        { $accounts->{$db->{$key}->name}{"name"} = $db->{$key}->name;
          $accounts->{$db->{$key}->name}{"password"} = $db->{$key}->password || "";
        }
        $accounts->{$db->{$key}->name}{"password"} ||= "";
        $accounts->{$db->{$key}->name}{"acs"} = 1;
        $accounts->{$db->{$key}->name}{"acs_description"} = $db->{$key}->description;
        $accounts->{$db->{$key}->name}{"acs_identitygroupname"} = $db->{$key}->identitygroupname->name;
        # Table relationship to ds_ise_identitygroup
        # THIS one is a strange fix for the way DBIX::Class handles has_many with singular and plural names - Tricky part is for ISE more than for ACS!
        $accounts->{$db->{$key}->name}{"acs_enabled"} = bool($db->{$key}->enabled);
        $accounts->{$db->{$key}->name}{"acs_enablepassword"} = $db->{$key}->enablepassword;
        $accounts->{$db->{$key}->name}{"acs_passwordneverexpires"} = bool($db->{$key}->passwordneverexpires);
        $accounts->{$db->{$key}->name}{"acs_password"} = $db->{$key}->password;
        $accounts->{$db->{$key}->name}{"acs_passwordtype"} = $db->{$key}->passwordtype;
        $accounts->{$db->{$key}->name}{"acs_dateexceeds"} = $db->{$key}->dateexceeds;
        $accounts->{$db->{$key}->name}{"acs_dateexceedsenabled"} = bool($db->{$key}->dateexceedsenabled);
        $accounts->{$db->{$key}->name}{"acs_id"} = $db->{$key}->id;
        
        $acs{$db->{$key}->name}  = 1;
      }
      if (ref($db->{$key}) eq "NG::Schema::Result::DsIntermapperUser")
      { if (!$accounts->{$db->{$key}->name}{"name"})
        { $accounts->{$db->{$key}->name}{"name"} = $db->{$key}->name;
          $accounts->{$db->{$key}->name}{"password"} = $db->{$key}->password || "";
        }
        $accounts->{$db->{$key}->name}{"password"} ||= "";
        
        $accounts->{$db->{$key}->name}{"intermapper"} = 1;
        $accounts->{$db->{$key}->name}{"intermapper_groups"} = $db->{$key}->groups || "";
        $accounts->{$db->{$key}->name}{"intermapper_external"} = bool($db->{$key}->external);
        $accounts->{$db->{$key}->name}{"intermapper_guest"} = $db->{$key}->guest;
        $accounts->{$db->{$key}->name}{"intermapper_id"} = $db->{$key}->id;

        $intermapper{$db->{$key}->name} = 1;
      }
      if (ref($db->{$key}) eq "NG::Schema::Result::DsIseInternaluser")
      { if (!$accounts->{$db->{$key}->name}{"name"})
        { $accounts->{$db->{$key}->name}{"name"} = $db->{$key}->name;
          $accounts->{$db->{$key}->name}{"password"} = $db->{$key}->password;
        }
        $accounts->{$db->{$key}->name}{"password"} ||= "";
        
        $accounts->{$db->{$key}->name}{"ise"} = 1;
        $accounts->{$db->{$key}->name}{"ise_email"} = $db->{$key}->email; 
        $accounts->{$db->{$key}->name}{"ise_firstname"} = $db->{$key}->firstname;
        $accounts->{$db->{$key}->name}{"ise_lastname"} = $db->{$key}->lastname;        
        $accounts->{$db->{$key}->name}{"ise_identitygroups"} = $db->{$key}->identitygroup->name;
        # Table relationship to ds_ise_identitygroup
        # THIS one is a strange fix for the way DBIX::Class handles has_many with singular and plural names!
        $accounts->{$db->{$key}->name}{"ise_changepassword"} = bool($db->{$key}->changepassword);
        $accounts->{$db->{$key}->name}{"ise_enabled"} = bool($db->{$key}->enabled);
        $accounts->{$db->{$key}->name}{"ise_enablepassword"} = $db->{$key}->enablepassword;
        $accounts->{$db->{$key}->name}{"ise_password"} = $db->{$key}->password;
        $accounts->{$db->{$key}->name}{"ise_passwordidstore"} = $db->{$key}->passwordidstore;
        $accounts->{$db->{$key}->name}{"ise_expirydate"} = $db->{$key}->expirydate;
        $accounts->{$db->{$key}->name}{"ise_expirydateenabled"} = bool($db->{$key}->expirydateenabled);
        $accounts->{$db->{$key}->name}{"ise_id"} = $db->{$key}->id;
      }
      $acs->users(users => \%acs);
      $intermapper->users(\%intermapper);
    }
  }
}

sub bool
{ return " checked" if $_[0];
}

sub synchronize # REVIEW!!
{ my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in'); 
  my $filter = $self->param("filter");
  my @mappings = ();
  
  my $mapping_rs = $self->db->resultset('Mapping');
  my $query_rs = $mapping_rs->search({ source_table => "Users" });
  while (my $mapping = $query_rs->next)
  { my ($source_ds, $source_table, $source_field, $destination_ds, $destination_table, $destination_field, $create, $append, $overwrite) =
   ($mapping->source_ds, $mapping->source_table, $mapping->source_field, $mapping->destination_ds, $mapping->destination_table,
    $mapping->destination_field, $mapping->createflag, $mapping->appendflag, $mapping->overwriteflag);
    push(@mappings,
         { source_ds => $source_ds, source_table => $source_table, source_field => $source_field,
           destination_ds => $destination_ds, destination_table => $destination_table, destination_field => $destination_field,
           create => $create, append => $append, overwrite => $overwrite
         });
  }
  
  my $acs_rs = $self->db->resultset('DsAcsUser');
  $query_rs = $acs_rs->search;
  while (my $account = $query_rs->next)
  { my %account = $account->get_columns;
    for my $map (@mappings)
    { if  ($map->{source_ds} == 1)  # ACS
      { if (my ($sfield) = $map->{source_field} =~ /^dynamic: (.*)$/) # Source field dynamic - Probably only for name
        { if (my ($dfield, $dvalue) = $map->{destination_field} =~ /^dynamic: (\S*)\s?(\S*)$/) # Destination field dynamic - Probably only for name
          { # ACS to Intermapper
            $sfield =~ s/[\r\n]//g; $dfield =~ s/[\r\n]//g;
            if ($map->{destination_ds} == 2)
            { my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
              my %criteria = (); #($dfield => $account{$sfield});
              $criteria{"name"} = $account{"name"};
              my $im_rs = $intermapper_rs->search({ %criteria }); # find all IM records with name matching sourcd DS, create if needed
              my $empty = 1;
              while (my $imaccount = $im_rs->next)
              { if ($map->{"overwrite"} eq "1") # APPEND FUNCTIONALITY TO DO!!
                { if (!$dvalue)
                  { $imaccount->update({ $dfield => $account{"$sfield"} }) ; } else
                  { $dvalue =~ s/\"//g; $imaccount->update({ $dfield => $dvalue }) ; }
                }
                $empty = 0;
              }
              if ($empty)  # No records matching criteria already exist - insert!
              { if ($map->{"create"} eq "1") 
                { $self->db->resultset('DsIntermapperUser')->create({ $dfield => $account{"acs_$sfield"} });
                }
              }
            }
            # ACS to ISE
            
            if ($map->{destination_ds} == 3)
            { my $ise_rs = $self->db->resultset('DsIseInternaluser');
              my %criteria = (); #($dfield => $account{$sfield});
              # if ($sfield ne "name") # Onlu use NAME field!!
              $criteria{"name"} = $account{"name"}; 
              my $cise_rs = $ise_rs->search({ %criteria });
              my $empty = 1;
              while (my $iseaccount = $cise_rs->next)
              { if ($map->{"overwrite"} eq "1") # APPEND FUNCTIONALITY TO DO!!
                { if (!$dvalue)
                 { $iseaccount->update({ $dfield => $account{"$sfield"} }) ; } else
                 { $dvalue =~ s/\"//g; $iseaccount->update({ $dfield => $dvalue }) ;
                 } 
                }
                $empty = 0;
              }
              if ($empty) 
              { if ($map->{"create"} eq "1")
                { $self->db->resultset('DsIseInternaluser')->create({ $dfield => $account{"acs_$sfield"} });
                }
              }
            }

          }
          
        } # source_field and destination_field dynamic
                
        if (my ($sfield, $svalue) = $map->{source_field} =~ /^static: (.*?) \"(.*?)\"$/) # Source field static - Probably only for name
        { if (my ($dfield,$dvalue) = $map->{destination_field} =~ /^static: (.*?) \"(.*?)\"$/) # Destination field static - Probably only for name
          { # ACS to Intermapper
            if ($map->{destination_ds} == 2)
            { if ($svalue && $account{"$sfield"} && $account{"$sfield"} eq $svalue)
              { my $intermapper_rs = $self->db->resultset('DsIntermapperUser');
                my %criteria = ("name" => $account{"name"}); # Find record in IM db matchin name
                my $im_rs = $intermapper_rs->search({ %criteria });
                if ($im_rs) # Records matching criteria already exist - only update!
                { while (my $imaccount = $im_rs->next)
                  { if ($map->{"append"} eq "1")
                    { $dvalue = $dvalue && $imaccount->{$dfield} ? $imaccount->{$dfield}.$dvalue : $imaccount->{$dfield};
                      $imaccount->update({ $dfield => $dvalue }) ;
                    }
                    if ($map->{"overwrite"} eq "1")
                    { $imaccount->update({ $dfield => $dvalue }) ;
                    }
                  }
                } else  # No records matching criteria already exist - insert!
                { if ($map->{"create"} eq "1")
                  { $self->db->resultset('DsIntermapperUser')->create({ "name" => $account{"name"}, $dfield => $dvalue });
                  }
                }
              }
            }

            # ACS to ISE
            if ($map->{destination_ds} == 3)
            { my $svfield = $account{"$sfield"} || "";
              if ($svalue eq $svfield)
              { my $ise_rs = $self->db->resultset('DsIseInternaluser');
                my %criteria = ("name" => $account{"name"}); # Find record in IM db matchin name
                my $cise_rs = $ise_rs->search({ %criteria });
                if ($cise_rs) # Records matching criteria already exist - only update!
                { while (my $iseaccount = $cise_rs->next)
                  { if ($map->{"append"} eq "1")
                    { $dvalue ||= "";
                      $iseaccount->{$dfield} ||= "";
                      $iseaccount->update({ $dfield => $iseaccount->{$dfield}.$dvalue }) ;
                    }
                    if ($map->{"overwrite"} eq "1")
                    { $iseaccount->update({ $dfield => $dvalue }) ;
                    }
                  }
                } else  # No records matching criteria already exist - insert!
                { if ($map->{"create"} eq "1")
                  { $self->db->resultset('DsIseInternaluser')->create({ "name" => $account{"name"}, $dfield => $dvalue });
                  }
                }
              }
            }
          }
        } # source_field and destination_field static
        
      } # source_ds = 1      
    }
  }

  if ($filter)
  { $self->redirect_to("/accounts/?filter=$filter");
  } else
  { $self->redirect_to("/accounts/"); }
}

1;
