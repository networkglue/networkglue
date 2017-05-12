package NG;
use Mojo::Base 'Mojolicious';
use NG::Schema;

use Net::Cisco::ACS;
use Net::Intermapper;
use Net::Cisco::ISE;
use Net::HP::NA;

use Crypt::Rijndael;
use Crypt::CBC;

# This method will run once at server start
sub startup {
  my $self = shift;

  my $schema = NG::Schema->connect("dbi:Pg:dbname=ng; host=localhost","ngpguser","ngpgpassword");
  $self->helper(db => sub { return $schema; });
  $self->helper(key => sub { return "Some Secret Key. Happy Happy Joy" }); # 32 bytes is the required key size
  $self->helper(salt => sub { return "ThisSaltKeyMayChange____1234567890" }); # Salt value
  
  my $cipher = Crypt::CBC->new( -cipher => 'Rijndael', -key => $self->key );
  $self->helper(cipher => sub { return $cipher; });
  
  $self->helper("datasources" => sub
                { my %datasources = ();
                  my %sources = %{ $self->sources() };
                  for my $source (keys %sources)
                  { if ($sources{$source}->type->shortname eq "ACS") 
                    { $datasources{$sources{$source}->id} = Net::Cisco::ACS->new(hostname => $sources{$source}->hostname, username => $sources{$source}->username, password => $sources{$source}->password, ssl => $sources{$source}->ssl); }
                    if ($sources{$source}->type->shortname eq "Intermapper") 
                    { $datasources{$sources{$source}->id} =  Net::Intermapper->new(hostname => $sources{$source}->hostname, username => $sources{$source}->username, password => $sources{$source}->password, ssl => $sources{$source}->ssl); }
                    if ($sources{$source}->type->shortname eq "ISE") 
                    { $datasources{$sources{$source}->id} = Net::Cisco::ISE->new(hostname => $sources{$source}->hostname, username => $sources{$source}->username, password => $sources{$source}->password, ssl => $sources{$source}->ssl, debug => 0); }
                    if ($sources{$source}->type->shortname eq "NA") 
                    { $datasources{$sources{$source}->id} = Net::HP::NA->new(hostname => $sources{$source}->hostname, username => $sources{$source}->username, password => $sources{$source}->password, ssl => $sources{$source}->ssl, debug => 0); }
					
                  }
                  return %datasources;
                });
  
  $self->helper("items" => sub
                { $self->sources();
                });
  
  $self->secrets(['This is the new session key for NG', 'This key is only for Validation - Not sure what that means']);
  $self->app->sessions->cookie_name('ng');
  $self->app->sessions->default_expiration('600');
  
  $self->plugin('resourceful_routes');
  # Router
  my $r = $self->routes;
  
  $r->route('/datasources/import/')->to('datasources#import');
  $r->route('/datasources/synchronize/')->to('datasources#synchronize');

  $r->route('/accounts/synchronize/')->to('accounts#synchronize');
  
  $self->resources('datasources');
  #$self->resources('devices');
  #$self->resources('devicegroups');  
  $self->resources('accountgroups');
  $self->resources('accounts');
  $self->resources('mappings'); 
  $self->resources('authentication'); 

  $r->route('/sync/rules/')->to('syncrules#index');
  $r->route('/sync/mappings/')->to('mappings#index');  
 
  $r->route('/datasources/new/:target')->to('datasources#new_form');
  $r->route('/authentication/new/:target')->to('authentication#new_form');

  # Normal route to controller
  $r->get('/')->to('main#index');
  $r->post('/init')->to('login#init');
  $r->get('/init')->to('login#init');
  $r->get('/login')->to('login#index');
  $r->get('/logout')->to('login#logout');
  $r->post('/login')->to('login#on_user_login');
  $r->route('/naam/')->to('naam#index');

  $r->get('/check')->to('login#check');

}

sub sources { 
  my $self = shift;
  my $sources_rs = $self->db->resultset('DsSource');
  my $query_rs = $sources_rs->search;
  my $sources = {};

  while (my $source = $query_rs->next)
  { $sources->{$source->type->shortname} = $source;
  }
  return $sources;
}

1;
