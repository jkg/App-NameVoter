package App::NameVoter;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Dancer::Plugin::Ajax;

use JSON::Any;

our $VERSION = '0.001';

get '/' => sub {
    template 'index';
};

post '/login' => sub {
	if ( params->{name} ) {
		session user => params->{name};
		redirect '/vote';
	}
};

get '/vote' => sub {
	redirect '/' unless session('user');
	template 'vote', { name => session('user') };
};

ajax '/show' => sub {

};

ajax '/save' => sub {

};

'0 but true';
