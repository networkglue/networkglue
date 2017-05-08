package NG::Process::Intermapper; 

use lib qw(lib);

use warnings;
use strict;

use NG::Schema;
use Net::Intermapper;
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
    if ($type->shortname eq "Intermapper") 
    { $self->{"Intermapper"}{$source->id} = Net::Intermapper->new(hostname => $source->hostname, username => $source->username, password => $source->password, ssl => $source->ssl); # ssl=> $source->ssl);
    }
  }
  bless $self, $class;
  return $self;
}

# Source Intermapper - Destination NG    
sub load_users
{ my $self = shift;
  for my $sourceid (keys %{$self->{"Intermapper"}})
  { my $users = $self->{"Intermapper"}{$sourceid}->users;
    my %users = % { $users };

    my $im_rs = $self->{"DB"}->resultset('DsIntermapperUser');
    my $query_rs = $im_rs->search({source => $sourceid });
    my %imusers = ();
    while (my $account = $query_rs->next)
    { $imusers{$account->name} = $account;
    }
    for my $user (keys %users)
    { if (!$imusers{$user})
      { my $status = $status_imported;
        $users{$user}->External("false") unless $users{$user}->External;
        my $encpassword = encode_base64($self->{"CIPHER"}->encrypt($self->{"SALT"}.$users{$user}->Password.$user));
        $self->{"DB"}->resultset('DsIntermapperUser')->create(
            { groups => $users{$user}->Groups, name => $users{$user}->Name, guest => $users{$user}->Guest, 
              status => $status, id => $users{$user}->Id, password => $encpassword, external => $users{$user}->External,
              uid => $sourceid."-".$users{$user}->Id, source => $sourceid
            });
      }
  
      if ($imusers{$user})
      { my $status = $status_synchronized;
        my $encpassword = encode_base64($self->{"CIPHER"}->encrypt($self->{"SALT"}.$users{$user}->Password.$user));
        $imusers{$user}->update(
            { groups => $users{$user}->Groups, name => $users{$user}->Name, guest => $users{$user}->Guest, source => $sourceid,
              status => $status, password => $encpassword, external => $users{$user}->External, uid => $sourceid."-".$users{$user}->Id
            });
      }
    }
  }
}

# Source NG - Destination Intermapper
sub export_users
{ my $self = shift;
  my @changed = ();
  my $im_rs = $self->{"DB"}->resultset('DsIntermapperUser');
  my $query_rs = $im_rs->search();

  while (my $account = $query_rs->next)
  { my $decpassword = undef;
    my $user = $account->name;
    my $salt = $self->{"SALT"};
    next if $account->status == 0;
    next if $account->status == 4;
    next if $account->status == 5;
    if ($account->password && length($account->password) > 64)
    { $decpassword = $self->{"CIPHER"}->decrypt(decode_base64($account->password));
    } else
    { $decpassword = $account->password; }

    $user = Net::Intermapper::User->new(Name => $account->name, Groups => "Users");
    $user->Password($decpassword) if $decpassword;
        
    my $response = $self->{"Intermapper"}->update($user) if $account->status eq $status_changed;
    $response = $self->{"Intermapper"}->create($user) if $account->status eq $status_created;
    $response = $self->{"Intermapper"}->delete($user) if $account->status eq $status_deleted;
    # Do something with $response here
  }
}

1;