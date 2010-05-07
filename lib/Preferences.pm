package Preferences;
use Moose;

has 'username' => (
	is			=>'rw',
	isa			=>'Str',
	predicate	=>'has_username'
);

has 'password' => (
	is			=>'rw',
	isa			=>'Str',
	predicate	=>'has_password'
);

sub BUILD {
	my $self = shift;
	
	$self->read_prefs();
}

sub login_check {
	my $self = shift;

	if($self->has_username && $self->has_password) {
		return 1;
	} else {
		return 0;
	}
}

sub check_os {
	my $self = shift;

	## If the preference file exists get the information ##
	if ( $^O =~ /MSWin32/ ) {
		return 'win';
	} else {
		# if not Windows then assumed *nix based OS
		return 'nix';
	}
}

sub read_prefs {
	my $self = shift;

	my $file;
	if(check_os() eq 'nix') {
		my $home = $ENV{'HOME'};
		if(-d "$home/.pwitter") {
			unless(chdir("$home/.pwitter")) {
				print "Problem changing directory\n";
				return;
			}
			$file = "$home/.pwitter/preferences.cfg";
		} else {
			$file = "preferences.cfg";
		}
	} else {
		$file = "preferences.cfg";
	}

	if(-e $file) {
		open(PREFS, $file) || warn "could not open preferences file: ($file)\n";

		while(<PREFS>) {
			my $line = $_;
			unless(substr($line,0,1) eq '#') {
				my @temp = split(/:/, $line);

				if($temp[0] eq "username" && $temp[1] ne "") {
					my $t = $temp[1];
					chomp($t);
					$self->username($t);
				}
				if($temp[0] eq "password" && $temp[1] ne "") {
					my $t = $temp[1];
					chomp($t);
					$self->password($t);
				}
			}
		}

		close(PREFS);
	}
}

sub save {
	my ($self, $username, $password) = @_;
	
	my $file = 'preferences.cfg';

	if(check_os() eq 'nix') {
		my $home = $ENV{'HOME'};
		unless(-d "$home/.pwitter") {
			mkdir("$home/.pwitter");
		}
		unless(chdir("$home/.pwitter")) {
			print "Problem changing directory\n";
			return;
		}
		$file = "$home/.pwitter/preferences.cfg";
	}

	open(PREFS, ">$file") || warn "could not write preferences file: ($file)\n";
	print PREFS "## Pwitter preference file ##\n";
	print PREFS "username:" . $self->username . "\n";
	print PREFS "password:" . $self->password . "\n";

	close(PREFS);
}

1;
