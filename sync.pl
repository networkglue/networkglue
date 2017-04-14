#!/usr/bin/perl

use lib qw(lib);
use Parallel::ForkManager;
use NG::Process::ACS;
use NG::Process::ISE;
use NG::Process::Intermapper;
use Crypt::CBC;
use Crypt::Rijndael;
use NG::Schema;

my $max_forks = 0;

my $key = "Some Secret Key. Happy Happy Joy";  # 32 bytes is the required key size
my $salt = "ThisSaltKeyMayChange____1234567890"; # Salt value
my $cipher = Crypt::CBC->new( -cipher => 'Rijndael', -key => $key );


my $fork = new Parallel::ForkManager($max_forks);
my $db = NG::Schema->connect("dbi:Pg:dbname=ng; host=localhost","ngpguser","ngpgpassword");

my $acs = NG::Process::ACS->new("db" => $db, "cipher" => $cipher, "key" => $key, "salt" => $salt);
my $im = NG::Process::Intermapper->new("db" => $db, "cipher" => $cipher, "key" => $key, "salt" => $salt);
my $ise = NG::Process::ISE->new("db" => $db, "cipher" => $cipher, "key" => $key, "salt" => $salt);

&load_identitygroups($acs, $ise, $im); # CALL TO NG::Process::ACS::load_identitygroups
&export_identitygroups($acs, $ise, $im); # CALL TO NG::Process::ACS::export_identitygroups

&load_users($acs, $ise, $im); # CALL TO NG::Process::ACS::load_users
&export_users($acs, $ise, $im); # CALL TO NG::Process::ACS::export_users

$fork->wait_all_children;

sub load_users
{ my $acs = shift;
  my $ise = shift;
  my $im = shift;
  fork_api_call($acs, 'load_users'); # CALL TO NG::Process::ACS::load_users
  fork_api_call($im, 'load_users');
  fork_api_call($ise, 'load_users');
  #print "forked API load_users...\n";
}

sub export_users
{ my $acs = shift;
  my $ise = shift;
  my $im = shift;
  fork_api_call($acs, 'export_users');
  fork_api_call($im, 'export_users');
  fork_api_call($ise, 'export_users');
  #print "forked API export_users...\n";
}

sub load_identitygroups
{ my $acs = shift;
  my $ise = shift;
  fork_api_call($acs, 'load_identitygroups'); # CALL TO NG::Process::ACS::load_identitygroups
  fork_api_call($ise, 'load_identitygroups'); # CALL TO NG::Process::ISE::load_identitygroups
  #print "forked API load_identitygroups...\n";
}

sub export_identitygroups
{ my $acs = shift;
  my $ise = shift;
  fork_api_call($acs, 'export_identitygroups');
  fork_api_call($ise, 'export_identitygroups'); # NOT SUPPORTED!!
  #print "forked API export_identitygroups...\n";
}

sub fork_api_call
{ my ($acs, $sub) = @_;
  for (0..$max_forks)
  { $fork->start and last;
    $acs->$sub();
    $fork->finish;
  }
}