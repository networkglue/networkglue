package NG::Process::ISE; 

use lib qw(lib);

use warnings;
use strict;

use NG::Schema;
use Net::Cisco::ISE;
use Data::Dumper;

use Mojo::Log;
use Time::Local;
use MIME::Base64;

my $status_clean = 0;
my $status_changed = 1; # NG Entry Changed
my $status_created = 2; # NG Entry Created
my $status_deleted = 3; # NG Entry Deleted
my $status_imported = 4; # NG Entry Imported from API - new entry
my $status_synchronized = 5; # NG Entry Synchronized from API - existing entry

sub new {
  my $class = shift;
  my $self = {};
  my %params = @_;
  $self->{"DB"} = $params{"db"};
  my $log = Mojo::Log->new(path => 'log/development.log');  
  $self->{"LOG"} = $log;
  $self->{"SALT"} = $params{"salt"};
  $self->{"CIPHER"} = $params{"cipher"};
  my $rs = $self->{"DB"}->resultset('DsSource');
  my $query_rs = $rs->search();
  while (my $source = $query_rs->next)
  { my $type = $source->type;
    if ($type->shortname eq "ISE") 
    { $self->{"ISE"}{$source->id} = Net::Cisco::ISE->new(hostname => $source->hostname, username => $source->username, password => $source->password, ssl => $source->ssl, debug => 0);
    }
  }
  bless $self, $class;
  return $self;
}


# Source ISE - Destination NG    
sub load_users
{ my $self = shift;
  for my $sourceid (keys %{$self->{"ISE"}})
  { my $users = $self->{"ISE"}{$sourceid}->internalusers;
    my %users = % { $users };
    my $ise_rs = $self->{"DB"}->resultset('DsIseIdentitygroup');
    my $query_rs = $ise_rs->search({ source => $sourceid });
    my %groups = ();
    my %idgroups = ();
    while (my $accountgroup = $query_rs->next)
    { $groups{$accountgroup->name} = $accountgroup->uid;
      $idgroups{$accountgroup->uid} = $accountgroup;
    }
    # ISE account not in NG DB -> create
    my $rs = $self->{"DB"}->resultset('DsIseInternaluser');
    $query_rs = $rs->search( { source => $sourceid });
    my %iseusers = ();
    while (my $account = $query_rs->next)
    { $iseusers{$account->name} = $account;
    }
    for my $user (keys %users)
    { $users{$user} = $self->{"ISE"}{$sourceid}->internalusers(id => $users{$user}->id);
      if (!$iseusers{$user})
      { my $usergroup = $idgroups{$sourceid."-".$users{$user}->identityGroups}; # Map ISE Name to ISE ID
        my $status = $status_imported;
        $self->{"DB"}->resultset('DsIseInternaluser')->create(
            { enabled => $users{$user}->enabled, identitygroups => $usergroup->uid, uid => $sourceid."-".$users{$user}->id,
              expirydateenabled => $users{$user}->expiryDateEnabled, email => $users{$user}->email, source => $sourceid,
              expirydate => $users{$user}->expiryDate, name => $users{$user}->name, passwordidstore => $users{$user}->passwordIDStore,
              status => $status, id => $users{$user}->id, firstname => $users{$user}->firstName, lastname => $users{$user}->lastName,
            });
      }
  # Net::Cisco::ISE::Mock now supports created and lastModified
    }
  }
}

# Source NG - Destination ISE
sub export_users
{ my $self = shift;
  my @changed = ();
  my $ise_rs = $self->{"DB"}->resultset('DsIseIdentitygroup');
  my $query_rs = $ise_rs->search();
  my %groups = ();
  my %idgroups = ();
  while (my $accountgroup = $query_rs->next)
  { $groups{$accountgroup->name} = $accountgroup->uid;
    $idgroups{$accountgroup->uid} = $accountgroup;
  }
  my $rs = $self->{"DB"}->resultset('DsIseInternaluser');
  $query_rs = $rs->search( );

  while (my $account = $query_rs->next)
  { my $decpassword;
    my $decenablepassword;
    my $user = $account->name;
    my $salt = $self->{"SALT"};
    next if $account->status == 0;
    next if $account->status == 4;
    next if $account->status == 5;
    if ($account->password && length($account->password) > 64)
    { $decpassword = $self->{"CIPHER"}->decrypt(decode_base64($account->password));
      $decpassword =~ s/^$salt//;
      $decpassword =~ s/$user$//;
    } else
    { $decpassword = $account->password; }
    if ($account->enablepassword && length($account->enablepassword) > 64)
    { $decenablepassword = $self->{"CIPHER"}->decrypt(decode_base64($account->enablepassword));
      $decenablepassword =~ s/^$salt//;
      $decenablepassword =~ s/$user$//;
    } else
    { $decenablepassword = $account->enablepassword; }
    $user =
        Net::Cisco::ISE::InternalUser->new(name => $account->name, identityGroups => $account->identitygroup->id,
          enabled => $account->enabled, firstName => $account->firstname, lastName => $account->lastname,
          email => $account->email, changePassword => $account->changepassword, passwordIDStore => $account->passwordidstore,
          expiryDate => $account->expirydate, expiryDateEnabled =>$account->expirydateenabled, id => $account->id);
    $user->password($decpassword) if $decpassword;
    $user->enablePassword($decenablepassword) if $decenablepassword;
    my $source = $account->source->id;
    $self->{"ISE"}{$source}->update($user) if $account->status eq $status_changed;
    $self->{"ISE"}{$source}->create($user) if $account->status eq $status_created;
    $self->{"ISE"}{$source}->delete($user) if $account->status eq $status_deleted;
    
    $account->update({ "status" => $status_synchronized }) ;    
  }
}


# Source ISE - Destination NG    
sub load_identitygroups
{ my $self = shift;
  for my $sourceid (keys %{$self->{"ISE"}})
  { my $identitygroups = $self->{"ISE"}{$sourceid}->identitygroups;
    my %identitygroups = % { $identitygroups };
    my $ise_rs = $self->{"DB"}->resultset('DsIseIdentitygroup');
    my $query_rs = $ise_rs->search();
    my %iseidentitygroups = ();
    while (my $group = $query_rs->next)
    { $iseidentitygroups{$group->name} = $group;
    }
    for my $identitygroup (keys %identitygroups)
    { if (!$iseidentitygroups{$identitygroup})
      { my $status = $status_imported;
        $self->{"DB"}->resultset('DsIseIdentitygroup')->create(
            { description => $identitygroups{$identitygroup}->description, name => $identitygroups{$identitygroup}->name, source => $sourceid,
              status => $status, id => $identitygroups{$identitygroup}->id, uid => $sourceid."-".$identitygroups{$identitygroup}->id
            });
			}
  
      if ($iseidentitygroups{$identitygroup})
      { my $status = $status_synchronized;
        $iseidentitygroups{$identitygroup}->update(
            { description => $identitygroups{$identitygroup}->description, name => $identitygroups{$identitygroup}->name, source => $sourceid,
              status => $status, id => $identitygroups{$identitygroup}->id, uid => $sourceid."-".$identitygroups{$identitygroup}->id
            });      
      }
     # Net::Cisco::ISE::Mock now supports created and lastModified
    }
  }
}

=pod
# Source NG - Destination ISE
sub export_identitygroups
{ my $self = shift;
  my $ise_rs = $self->{"DB"}->resultset('DsIseIdentitygroup');
  my $query_rs = $ise_rs->search();

  while (my $group = $query_rs->next)
  { my $identitygroup =
        Net::Cisco::ISE::IdentityGroup->new(name => $group->name, description => $group->description, id => $group->id);
        
    $self->{"ISE"}->update($identitygroup) if $group->status eq $status_changed;
    $self->{"ISE"}->create($identitygroup) if $group->status eq $status_created;
    $self->{"ISE"}->delete($identitygroup) if $group->status eq $status_deleted;
  }
}
=cut
1;