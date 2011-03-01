package Tamel;
use Moose;
use Net::Twitter;
use FindBin;
use lib "$FindBin::Bin/lib";
use Preferences;

my $tw = Net::Twitter->new(traits => [qw/API::REST/]);

my $prefs = Preferences->new();

sub BUILD {
	my $self = shift;
}

sub login {
	my $self = shift;

	unless (prefs_check()) {
		return 0;
	}
	
	$tw->credentials($prefs->username,$prefs->password);
}

sub update {
	my ($self, $t) = @_;

	my $return = $tw->update($t);
}

sub timeline {
	my $self = shift;

	my $date = DateTime->now();

	my @temp_ary = [];

	eval {
		$date->subtract(days=>7);
		my $statuses = $tw->friends_timeline({ since_id => $date, count => 25});
		for my $status (@$statuses) {
			my $t = $status->{created_at};
			$t =~ tr/\+//d;
			my @d_t = split(/ /, $t);
			my $temp_time = $d_t[1] . ' ' . $d_t[2] . ' @ ' . $d_t[3];
			
			my @temp = [$temp_time, $status->{user}{screen_name}, $status->{text}];
			
			push(@temp_ary, @temp);
		}
	};

	if(my $err = $@) {
		@temp_ary = [];
		push(@temp_ary, "Unknown problem fetching timeline.") unless blessed $err && $err->isa('Net::Twitter::Error');
		
		push(@temp_ary, "HTTP Response Code: $err->code\n");
		push(@temp_ary, "HTTP Message......: $err->message\n");
		push(@temp_ary, "Twitter Error.....: $err->error\n");
	}
	
	return @temp_ary;
}

sub prefs_check {
	my $self = shift;

	if($prefs->has_username && $prefs->has_password
		&& $prefs->username ne '' && $prefs->password ne '') {
		return 1;
	} else {
		return 0;
	}
}

sub set_u_p {
	my ($self, $u, $p) = @_;

	print "\n|" . $prefs->username . "|" .$prefs->password . "|" . $u . "|" . $p . "|\n";

	$prefs->username($u);
	$prefs->password($p);
}

sub get_u_p {
	my $self = shift;

	my $u = '';
	my $p = '';

	if($prefs->has_username) {
		$u = $prefs->username;
	}
	if($prefs->has_password) {
		$p = $prefs->password;
	}

	my @temp = ($u, $p);
	
	return @temp;
}

sub save_prefs {
	my $self = shift;

	$prefs->save();
}

1;
