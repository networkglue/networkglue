package NG::Process::ACS; 

use lib qw(lib);

use warnings;
use strict;

use NG::Schema;
use Net::Cisco::ACS;
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
    if ($type->shortname eq "ACS") 
    { $self->{"ACS"}{$source->id} = Net::Cisco::ACS->new(hostname => $source->hostname, username => $source->username, password => $source->password, ssl => $source->ssl); 
    }
  }
  bless $self, $class;
  return $self;
}


# Source ACS - Destination NG    
sub load_users
{ my $self = shift;
  for my $sourceid (keys %{$self->{"ACS"}})
  { my $users = $self->{"ACS"}{$sourceid}->users;
    my %users = % { $users };
    my $acs_rs = $self->{"DB"}->resultset('DsAcsIdentitygroup');
    my $query_rs = $acs_rs->search( {source => $sourceid });
    my %groups = ();
    my %idgroups = ();
    while (my $accountgroup = $query_rs->next)
    { $groups{$accountgroup->name} = $accountgroup->uid;
      $idgroups{$accountgroup->uid} = $accountgroup->name;
    }
    # ACS account not in NG DB -> create
    my $rs = $self->{"DB"}->resultset('DsAcsUser');
    $query_rs = $rs->search({ source => $sourceid });
    my %acsusers = ();
    while (my $account = $query_rs->next)
    { $acsusers{$account->name} = $account;
    }
    my %months = ("Jan" => 0,"Feb" => 1,"Mar" => 2,"Apr" => 3,"May" => 4,"Jun" => 5,"Jul" => 6,"Aug" => 7,"Sep" => 8,"Oct" => 9,"Nov" => 10,"Dec" => 11);
    my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    for my $user (keys %users)
    { if (!$acsusers{$user})
      { my $usergroup = $groups{$users{$user}->identityGroupName}; # Map ACS Name to ACS ID
        my $status = $status_imported;
        my $moddate = $users{$user}->lastModified;
        my $createdate = $users{$user}->created;
        $self->{"DB"}->resultset('DsAcsUser')->create(
            { enabled => $users{$user}->enabled, description => $users{$user}->description, identitygroupname => $usergroup,
              passwordneverexpires => $users{$user}->passwordNeverExpires, dateexceedsenabled => $users{$user}->dateExceedsEnabled,
              dateexceeds => $users{$user}->dateExceeds, passwordtype => $users{$user}->passwordType, name => $users{$user}->name, source => $sourceid,
              status => $status, id => $users{$user}->id, created => $createdate, lastmodified => $moddate, uid => $sourceid."-".$users{$user}->id
            });
      }
  
      if ($acsusers{$user})
      { my $usergroup = $groups{$users{$user}->identityGroupName};
        my $status = $status_synchronized;
        my $lastmod = $users{$user}->lastModified;
        my ($mon,$mday,$year,$hour,$minute,$second) = $lastmod =~ /^(\w{3})\s(\d{1,2})\s(\d{4})\s(\d{1,2})\:(\d{1,2})\:(\d{1,2})$/;
        my $dtime = timelocal( $second, $minute, $hour, $mday, $months{$mon}, $year );
  
        my $acslastmod = $acsusers{$user}->lastmodified;
      
        ($mon,$mday,$year,$hour,$minute,$second) = $acslastmod =~ /^(\w{3})\s(\d{1,2})\s(\d{4})\s(\d{1,2})\:(\d{1,2})\:(\d{1,2})$/;
        $year -= 1900;
        my $acstime = timelocal( $second, $minute, $hour, $mday, $months{$mon}, $year );
        $year += 1900;

        if ($acstime < $dtime) # If ACS account has been modified more recent than NG entry
        { $acsusers{$user}->update(
            { enabled => $users{$user}->enabled, description => $users{$user}->description, identitygroupname => $usergroup,
              passwordneverexpires => $users{$user}->passwordNeverExpires, dateexceedsenabled => $users{$user}->dateExceedsEnabled,
              dateexceeds => $users{$user}->dateExceeds, passwordtype => $users{$user}->passwordType, name => $users{$user}->name, source => $sourceid,
              status => $status, id => $users{$user}->id, lastmodified => $users{$user}->lastModified, uid => $sourceid."-".$users{$user}->id
            });
        }

        if ($acstime > $dtime) # If ACS account has been modified more recent than NG entry
        { my $idusergroup = $acsusers{$user}->identitygroupname->name;
          if (length($users{$user}->password) < 64)
          { my $encpassword = encode_base64($self->{"CIPHER"}->encrypt($self->{"SALT"}.$users{$user}->password.$user));
            $users{$user}->password($encpassword); 
            $acsusers{$user}->update( { password => $encpassword });
          }

          if (length($users{$user}->enablePassword) < 64)
          { my $encpassword = encode_base64($self->{"CIPHER"}->encrypt($self->{"SALT"}.$users{$user}->enablePassword.$user));
            $users{$user}->enablePassword($encpassword);
            $acsusers{$user}->update( { enablepassword => $encpassword });
          }

          my $decpassword = $self->{"CIPHER"}->decrypt(decode_base64($users{$user}->password));
          my $decenablepassword = $self->{"CIPHER"}->decrypt(decode_base64($users{$user}->enablePassword));
        
          my $salt = $self->{"SALT"};
          $decpassword =~ s/^$salt//;
          $decpassword =~ s/$user$//;
          $decenablepassword =~ s/^$salt//;
          $decenablepassword =~ s/$user$//;
          my $acsuser =
          Net::Cisco::ACS::User->new(name => $acsusers{$user}->name, description => $acsusers{$user}->description,
            identityGroupName => $idusergroup,
            enablePassword => $decenablepassword, enabled => $acsusers{$user}->enabled, password => $decpassword,
            passwordNeverExpires => $acsusers{$user}->passwordneverexpires, passwordType => $acsusers{$user}->passwordtype,
            dateExceeds => $acsusers{$user}->dateexceeds, dateExceedsEnabled =>$acsusers{$user}->dateexceedsenabled, id => $acsusers{$user}->id,
            );
          $self->{"ACS"}{$sourceid}->update($acsuser);
        }
      }
     # Net::Cisco::ACS::Mock now supports created and lastModified
    }
  }
}

# Source NG - Destination ACS
sub export_users
{ my $self = shift;
  my @changed = ();
  my $acs_rs = $self->{"DB"}->resultset('DsAcsIdentitygroup');
  my $query_rs = $acs_rs->search();
  my %groups = ();
  my %idgroups = ();
  while (my $accountgroup = $query_rs->next)
  { $groups{$accountgroup->name} = $accountgroup->uid;
    $idgroups{$accountgroup->uid} = $accountgroup->name;
  }
  my $rs = $self->{"DB"}->resultset('DsAcsUser');
  $query_rs = $rs->search();

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
        Net::Cisco::ACS::User->new(name => $account->name, description => $account->description,
          identityGroupName => $account->identitygroupname->name,
          enabled => $account->enabled, 
          passwordNeverExpires => $account->passwordneverexpires, passwordType => $account->passwordtype,
          dateExceeds => $account->dateexceeds, dateExceedsEnabled =>$account->dateexceedsenabled, id => $account->id);
    $user->password($decpassword) if $decpassword;
    $user->enablePassword($decenablepassword) if $decenablepassword;
    my $source = $account->source->id;
    $self->{"ACS"}{$source}->update($user) if $account->status eq $status_changed;
    $self->{"ACS"}{$source}->create($user) if $account->status eq $status_created;
    $self->{"ACS"}{$source}->delete($user) if $account->status eq $status_deleted;
  }
}


# Source ACS - Destination NG    
sub load_identitygroups
{ my $self = shift;
  for my $sourceid (keys %{$self->{"ACS"}})
  { my $identitygroups = $self->{"ACS"}{$sourceid}->identitygroups;
    my %identitygroups = % { $identitygroups };
    my $acs_rs = $self->{"DB"}->resultset('DsAcsIdentitygroup');
    my $query_rs = $acs_rs->search({ source => $sourceid });
    my %acsidentitygroups = ();
    while (my $group = $query_rs->next)
    { $acsidentitygroups{$group->name} = $group;
    }
    for my $identitygroup (keys %identitygroups)
    { if (!$acsidentitygroups{$identitygroup})
      { my $status = $status_imported;
        $self->{"DB"}->resultset('DsAcsIdentitygroup')->create(
            { description => $identitygroups{$identitygroup}->description, name => $identitygroups{$identitygroup}->name, source => $sourceid,
              status => $status, id => $identitygroups{$identitygroup}->id, uid => $sourceid."-".$identitygroups{$identitygroup}->id
            });
      }
  
      if ($acsidentitygroups{$identitygroup})
      { my $status = $status_synchronized;
        $acsidentitygroups{$identitygroup}->update(
            { description => $identitygroups{$identitygroup}->description, name => $identitygroups{$identitygroup}->name, source => $sourceid,
              status => $status, id => $identitygroups{$identitygroup}->id, uid => $sourceid."-".$identitygroups{$identitygroup}->id
            });      
      }
   # Net::Cisco::ACS::Mock now supports created and lastModified
    }
  }
}

# Source NG - Destination ACS
sub export_identitygroups
{ my $self = shift;
  my $acs_rs = $self->{"DB"}->resultset('DsAcsIdentitygroup');
  my $query_rs = $acs_rs->search();

  while (my $group = $query_rs->next)
  { my $identitygroup =
        Net::Cisco::ACS::IdentityGroup->new(name => $group->name, description => $group->description, id => $group->id);
        
    $self->{"ACS"}{$group->source}->update($identitygroup) if $group->status eq $status_changed;
    $self->{"ACS"}{$group->source}->create($identitygroup) if $group->status eq $status_created;
    $self->{"ACS"}{$group->source}->delete($identitygroup) if $group->status eq $status_deleted;
  }
}

1;