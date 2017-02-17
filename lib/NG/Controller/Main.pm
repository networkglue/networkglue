package NG::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub index {
  my $self = shift;
  $self->redirect_to('/login/') if !$self->session('logged_in');
  $self->redirect_to('/accounts/');
}

1;
