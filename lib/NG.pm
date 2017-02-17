package NG;
use Mojo::Base 'Mojolicious';
use NG::Schema;

use Net::Cisco::ACS;
use Net::Intermapper;
use Net::Cisco::ISE;
#use Net::HP::NA;

use Crypt::Rijndael;
use Crypt::CBC;

# This method will run once at server start
sub startup {
  my $self = shift;

  my $schema = NG::Schema->connect("dbi:Pg:dbname=ng; host=localhost","ngpguser","ngpgpassword");
  $self->helper(db => sub { return $schema; });
  $self->helper(key => sub { return "Some Secret Key. Happy Happy Joy" }); # 32 bytes is the required key size
  $self->helper(salt => sub { return "ThisSaltKeyMayChange!?!?1234567890" }); # Salt value
  
  my $cipher = Crypt::CBC->new( -cipher => 'Rijndael', -key => $self->key );
  $self->helper(cipher => sub { return $cipher; });
  
  $self->helper("datasources" => sub
                { my %datasources = ();
                  $datasources{"acs"} = Net::Cisco::ACS->new(hostname => '10.0.0.1', username => 'acsadmin', password => 'testPassword', mock => "1") unless $datasources{"acs"};
                  $datasources{"ise"} = Net::Cisco::ISE->new(hostname => '10.0.0.1', username => 'acsadmin', password => 'testPassword', mock => "1") unless $datasources{"ise"};
                  $datasources{"intermapper"} = Net::Intermapper->new(hostname => '10.0.0.1', username => 'acsadmin', password => 'testPassword', mock => "1") unless $datasources{"intermapper"};
                  #$datasources{"hpna"} = Net::HP::NA->new(hostname => '10.0.0.1', username => 'admin', password => 'testPassword', mock => "1") unless $datasources{"hpna"};                  
                  return %datasources;
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
  $self->resources('devices');
  $self->resources('accountgroups');
  $self->resources('accounts');
  $self->resources('mappings'); 
 
  $r->route('/datasources/new/:target')->to('datasources#new_form');
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

1;
