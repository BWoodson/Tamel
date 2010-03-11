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
	my ($self) = @_;

	my $file;
	if(check_os() eq 'nix') {
		if(-d '~/.pwitter') {
			unless(chdir('~/.pwitter')) {
				print "Problem changing directory\n";
				return;
			}
		}
			#	$file = "~/.pwitter/preferences.cfg";
	#} else {
		$file = "preferences.cfg";
	}

	print "\nfile: $file\n";
	
	if(-e $file) {
		print "\n\nfile: $file\n\n";
		open(PREFS, $file) || warn "could not open preferences file: ($file)\n";

		while(<PREFS>) {
			my $line = $_;
			my @temp = split(/:/, $line);

			if($temp[0] eq "username" && $temp[1] ne "") {
				$self->username($temp[1]);
			}
			if($temp[0] eq "password" && $temp[1] ne "") {
				$self->password($temp[1]);
			}
		}

		close(PREFS);
	}
}

sub write_prefs {
	my ($self, $username, $password) = @_;
	
	if(check_os() eq 'nix') {
		chdir();
		unless(-d ".pwitter") {
			mkdir(".pwitter");
		}
		unless(chdir(".pwitter")) {
			print "Problem changing directory\n";
			return;
		}
	}

	open(PREFS, ">preferences.cfg") || warn "could not write preferences file: (preferences.cfg)\n";
	print PREFS "## Pwitter preference file ##\n";
	print PREFS "username:" . $self->username . "\n";
	print PREFS "password:" . $self->password . "\n";

	close(PREFS);
}

1;
