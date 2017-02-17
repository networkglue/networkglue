#!/usr/bin/perl

use lib qw(lib);
use Parallel::ForkManager;
use NG::Process::ACS;
use NG::Schema;

my $max_forks = 0;

my $fork = new Parallel::ForkManager($max_forks);
my $api = NG::Process::ACS->new("db" => NG::Schema->connect("dbi:Pg:dbname=ng; host=localhost","ngpguser","ngpgpassword"));

&load_identitygroups($api); # CALL TO NG::Process::ACS::load_identitygroups
&export_identitygroups($api); # CALL TO NG::Process::ACS::export_identitygroups

&load_users($api); # CALL TO NG::Process::ACS::load_users
&export_users($api); # CALL TO NG::Process::ACS::export_users
$fork->wait_all_children;

sub load_users
{ my $api = shift;
  fork_api_call($api, 'load_users'); # CALL TO NG::Process::ACS::load_users
  #print "forked API load_users...\n";
}

sub export_users
{ my $api = shift;
  fork_api_call($api, 'export_users');
  #print "forked API export_users...\n";
}

sub load_identitygroups
{ my $api = shift;
  fork_api_call($api, 'load_identitygroups'); # CALL TO NG::Process::ACS::load_identitygroups
  #print "forked API load_identitygroups...\n";
}

sub export_identitygroups
{ my $api = shift;
  fork_api_call($api, 'export_identitygroups');
  #print "forked API export_identitygroups...\n";
}

sub fork_api_call
{ my ($api, $sub) = @_;
  for (0..$max_forks)
  { $fork->start and last;
    $api->$sub();
    $fork->finish;
  }
}