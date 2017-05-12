package NG::Process::NA; 

use lib qw(lib);

use warnings;
use strict;

use NG::Schema;
use Net::HP::NA;
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
    if ($type->shortname eq "NA") 
    { $self->{"NA"}{$source->id} = Net::HP::NA->new(hostname => $source->hostname, username => $source->username, password => $source->password, ssl => $source->ssl); 
	  $self->{"NA"}{$source->id}->ssl_options({ 'SSL_verify_mode' => "SSL_VERIFY_NONE", 'verify_hostname' => '0' });
    }
  }
  bless $self, $class;
  return $self;
}

# Source NA - Destination NG    
sub load_users
{ my $self = shift;
  for my $sourceid (keys %{$self->{"NA"}})
  { my $users = $self->{"NA"}{$sourceid}->users;
    my %users = % { $users };
    # NA account not in NG DB -> create
    my $rs = $self->{"DB"}->resultset('DsNaUser');
    my $query_rs = $rs->search({ source => $sourceid });
    my %nausers = ();
    while (my $account = $query_rs->next)
    { $nausers{$account->username} = $account;
    }
    my %months = ("Jan" => 0,"Feb" => 1,"Mar" => 2,"Apr" => 3,"May" => 4,"Jun" => 5,"Jul" => 6,"Aug" => 7,"Sep" => 8,"Oct" => 9,"Nov" => 10,"Dec" => 11);
    my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    for my $user (keys %users)
    { if (!$nausers{$user})
      { #my $usergroup = $groups{$users{$user}->identityGroupName}; # Map na Name to na ID
        my $status = $status_imported;
        #my $moddate = $users{$user}->lastModified;
        #my $createdate = $users{$user}->created;
		$users{$user}->allowFailover ? $users{$user}->allowFailover("t") : $users{$user}->allowFailover("f");
		$users{$user}->useAaaLoginForProxy ? $users{$user}->useAaaLoginForProxy("t") : $users{$user}->useAaaLoginForProxy("f");
        $self->{"DB"}->resultset('DsNaUser')->create(
            { userpassword => $users{$user}->userPassword, emailaddress => $users{$user}->emailAddress, comments => $users{$user}->comments,
		      distinguishedname => $users{$user}->distinguishedName, allowfailover => $users{$user}->allowFailover, username => $users{$user}->userName, 
			  timezone => $users{$user}->timeZone, firstname => $users{$user}->firstName, useaaaloginforproxy => $users{$user}->useAaaLoginForProxy, 
			  privilegelevel => $users{$user}->privilegeLevel, lastname => $users{$user}->lastName, passwordoption => $users{$user}->passwordOption, 
			  aaausername => $users{$user}->aaaUserName, status => $users{$user}->status, ticketnumber => $users{$user}->ticketNumber, 
			  userid => $users{$user}->userID, na_status => $status, source=> $sourceid, uid => $sourceid."-".$users{$user}->userID,#lastmodified => $lastmodified, created => $created,
            });
      }
  
      if ($nausers{$user})
      { my $status = $status_synchronized;
=pod
        my $lastmod = $users{$user}->lastModified;
        my ($mon,$mday,$year,$hour,$minute,$second) = $lastmod =~ /^(\w{3})\s(\d{1,2})\s(\d{4})\s(\d{1,2})\:(\d{1,2})\:(\d{1,2})$/;
        my $dtime = timelocal( $second, $minute, $hour, $mday, $months{$mon}, $year );
  
        my $nalastmod = $nausers{$user}->lastmodified;
      
        ($mon,$mday,$year,$hour,$minute,$second) = $nalastmod =~ /^(\w{3})\s(\d{1,2})\s(\d{4})\s(\d{1,2})\:(\d{1,2})\:(\d{1,2})$/;
        $year -= 1900;
        my $natime = timelocal( $second, $minute, $hour, $mday, $months{$mon}, $year );
        $year += 1900;

        if ($natime < $dtime) # If na account has been modified more recent than NG entry
        { 
=cut
		$nausers{$user}->update(
            { userpassword => $users{$user}->userPassword, emailaddress => $users{$user}->emailAddress, comments => $users{$user}->comments,
		      distinguishedname => $users{$user}->distinguishedName, allowfailover => $users{$user}->allowFailover, username => $users{$user}->userName, 
			  timezone => $users{$user}->timeZone, firstname => $users{$user}->firstName, useaaaloginforproxy => $users{$user}->useAaaLoginForProxy, 
			  privilegelevel => $users{$user}->privilegeLevel, lastname => $users{$user}->lastName, passwordoption => $users{$user}->passwordOption, 
			  aaausername => $users{$user}->aaaUserName, status => $users{$user}->status, ticketnumber => $users{$user}->ticketNumber, 
			  userid => $users{$user}->userID, na_status => $status, source=> $sourceid, uid => $sourceid."-".$users{$user}->userID,
            });
#        }
=pod
        if ($natime > $dtime) # If na account has been modified more recent than NG entry
        { my $idusergroup = $nausers{$user}->identitygroupname->name;
          if (length($users{$user}->password) < 64)
          { my $encpassword = encode_base64($self->{"CIPHER"}->encrypt($self->{"SALT"}.$users{$user}->password.$user));
            $users{$user}->password($encpassword); 
            $nausers{$user}->update( { password => $encpassword });
          }

          if (length($users{$user}->enablePassword) < 64)
          { my $encpassword = encode_base64($self->{"CIPHER"}->encrypt($self->{"SALT"}.$users{$user}->enablePassword.$user));
            $users{$user}->enablePassword($encpassword);
            $nausers{$user}->update( { enablepassword => $encpassword });
          }

          my $decpassword = $self->{"CIPHER"}->decrypt(decode_base64($users{$user}->password));
          my $decenablepassword = $self->{"CIPHER"}->decrypt(decode_base64($users{$user}->enablePassword));
        
          my $salt = $self->{"SALT"};
          $decpassword =~ s/^$salt//;
          $decpassword =~ s/$user$//;
          $decenablepassword =~ s/^$salt//;
          $decenablepassword =~ s/$user$//;
          my $nauser =
          Net::HP::na::User->new(name => $nausers{$user}->name, description => $nausers{$user}->description,
            identityGroupName => $idusergroup,
            enablePassword => $decenablepassword, enabled => $nausers{$user}->enabled, password => $decpassword,
            passwordNeverExpires => $nausers{$user}->passwordneverexpires, passwordType => $nausers{$user}->passwordtype,
            dateExceeds => $nausers{$user}->dateexceeds, dateExceedsEnabled =>$nausers{$user}->dateexceedsenabled, id => $nausers{$user}->id,
            );
          $self->{"na"}{$sourceid}->update($nauser);
        }
=cut
      }
    }
  }
}

# Source NG - Destination na
sub export_users
{ my $self = shift;
  my @changed = ();
  my $rs = $self->{"DB"}->resultset('DsNaUser');
  my $query_rs = $rs->search();
=pod
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
        Net::HP::NA::User->new(name => $account->name, description => $account->description,
          identityGroupName => $account->identitygroupname->name,
          enabled => $account->enabled, 
          passwordNeverExpires => $account->passwordneverexpires, passwordType => $account->passwordtype,
          dateExceeds => $account->dateexceeds, dateExceedsEnabled =>$account->dateexceedsenabled, id => $account->id);
    $user->password($decpassword) if $decpassword;
    $user->enablePassword($decenablepassword) if $decenablepassword;
    my $source = $account->source->id;
    $self->{"na"}{$source}->update($user) if $account->status eq $status_changed;
    $self->{"na"}{$source}->create($user) if $account->status eq $status_created;
    $self->{"na"}{$source}->delete($user) if $account->status eq $status_deleted;
  }
=cut
}


# Source na - Destination NG    
sub load_identitygroups
{ my $self = shift;
=pod
  for my $sourceid (keys %{$self->{"na"}})
  { my $identitygroups = $self->{"na"}{$sourceid}->identitygroups;
    my %identitygroups = % { $identitygroups };
    my $na_rs = $self->{"DB"}->resultset('DsnaIdentitygroup');
    my $query_rs = $na_rs->search({ source => $sourceid });
    my %naidentitygroups = ();
    while (my $group = $query_rs->next)
    { $naidentitygroups{$group->name} = $group;
    }
    for my $identitygroup (keys %identitygroups)
    { if (!$naidentitygroups{$identitygroup})
      { my $status = $status_imported;
        $self->{"DB"}->resultset('DsnaIdentitygroup')->create(
            { description => $identitygroups{$identitygroup}->description, name => $identitygroups{$identitygroup}->name, source => $sourceid,
              status => $status, id => $identitygroups{$identitygroup}->id, uid => $sourceid."-".$identitygroups{$identitygroup}->id
            });
      }
  
      if ($naidentitygroups{$identitygroup})
      { my $status = $status_synchronized;
        $naidentitygroups{$identitygroup}->update(
            { description => $identitygroups{$identitygroup}->description, name => $identitygroups{$identitygroup}->name, source => $sourceid,
              status => $status, id => $identitygroups{$identitygroup}->id, uid => $sourceid."-".$identitygroups{$identitygroup}->id
            });      
      }
   # Net::HP::na::Mock now supports created and lastModified
    }
  }
=cut
}

# Source NG - Destination na
sub export_identitygroups
{ my $self = shift;
=pod
  my $na_rs = $self->{"DB"}->resultset('DsnaIdentitygroup');
  my $query_rs = $na_rs->search();

  while (my $group = $query_rs->next)
  { my $identitygroup =
        Net::HP::na::IdentityGroup->new(name => $group->name, description => $group->description, id => $group->id);
        
    $self->{"na"}{$group->source}->update($identitygroup) if $group->status eq $status_changed;
    $self->{"na"}{$group->source}->create($identitygroup) if $group->status eq $status_created;
    $self->{"na"}{$group->source}->delete($identitygroup) if $group->status eq $status_deleted;
  }
=cut
}

1;