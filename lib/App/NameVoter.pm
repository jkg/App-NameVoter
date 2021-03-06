package App::NameVoter;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Dancer::Plugin::Ajax;

use JSON::Any;
use File::Slurp::Tiny qw/read_lines/;
use Time::Piece;

our $VERSION = '0.001';

my @strings = read_lines( 'data/pairs', chomp => 1 );

my $j = JSON::Any->new();

get '/' => sub {
    template 'index';
};

post '/login' => sub {
	if ( params->{name} ) {
		session user => params->{name};
		redirect '/vote';
	}
};

get '/results' => sub {
	redirect '/' unless session('user');

	my $sth_faves = database->prepare(
		'SELECT option, SUM(vote) AS score
		 FROM votes v WHERE EXISTS ( 
		 	SELECT * FROM votes WHERE v.option = option AND user = ? AND vote > 0
		 ) GROUP BY option ORDER BY SUM(vote) DESC'
	);
	$sth_faves->execute(session('user'));

	my $sth_overall = database->prepare(
		'SELECT option, SUM(vote) AS score
		 FROM votes 
		 GROUP BY option
		 HAVING score > 0
		 ORDER BY score DESC'
	) or die "failed to prepare sth";
	$sth_overall->execute();


	template 'results',
		{ 
			user_faves => $sth_faves->fetchall_arrayref({}),
			overall => $sth_overall->fetchall_arrayref({}),
		};
};

get '/vote' => sub {
	redirect '/' unless session('user');
	my @options = map { $strings[rand @strings] } ( 1..6 );
	template 'vote', { name => session('user'), options => \@options };
};

ajax '/show' => sub {
	my $user = session->{user} || return { result => 0 };
	my $string = $strings[rand @strings];

	return $j->to_json({ 
		option => $string, 
		user => session->{user},
		# TODO: need some secret sauce^Wdata here if we want this to be secure
	 });
};

ajax '/save' => sub {
	my $j = JSON::Any->new();

	debug "strings contains" . scalar @strings . " elements";

	# validate: vote is a legit value, string is one we know, nonce matches
	return $j->to_json( { result => 0 })
		unless grep { $_ == params->{vote} } ( -1 .. 1 );
	# 		&& grep +{ $_ eq params->{option} }, @strings;

	database->quick_insert( 'votes', {
		user => session->{user},
		option => params->{option},
		vote => params->{vote},
		timestamp => Time::Piece->new()->epoch(),
	}) or return $j->to_json( { result => 0 });

	return $j->to_json( { result => 1 });
};

'another stunning @jkg production';
