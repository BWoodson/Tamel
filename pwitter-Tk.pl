#!/usr/bin/perl -w

use Tk;
use strict;
use DateTime;
use Preferences;
use Net::Twitter;

## Preferences ##
my $pref = Preferences->new();

my $tw;

## Main Window ##
my $mw = new MainWindow(-title=>'Pwitter');

## Menu Setup ##
my $menu = $mw->Menu();
$mw->configure(-menu => $menu);

my $options_menu = $menu->cascade(-label=>"Options", -underline=>0, -tearoff=>0);
my $about_menu = $menu->cascade(-label=>"About", -underline=>0, -tearoff=>0);

$options_menu->command(-label=>"Refresh", -underline=>0, -command=>sub{ refresh(); });
$options_menu->command(-label=>"Settings", -underline=>0, -command=>sub{ settings(); });
$options_menu->separator();
$options_menu->command(-label=>"Exit", -underline=>1, -command=>sub{ exit });

$about_menu->command(-label=>"About", -underline=>0, -command=>sub{
				$mw->messageBox(-title=>"About",
								-message=>"Pwitter 0.1",
								-type=>"OK", -default=>"ok");});

## Content Area Frame ##
my $txt_frame = $mw->Frame(-background=>'yellow')->pack(-expand=>1, -fill=>'both');
my $txt = $txt_frame->Scrolled('Text', -scrollbars => 'oe', -width=>80, -height=>20,
								-wrap=>'word', -background=>'black', -foreground=>'white',
								-font=>['Times New Roman', 12])->pack(-expand=>1, -fill=>'both');

sub login {
	if($pref->login_check()) {
		$tw = Net::Twitter->new(
			traits		=> [qw/API::REST/],
			#username	=> $user,
			#password	=> $password
			username	=> 'ExoticFish',
			password	=> 'samsung'
		);
	} else {
		$mw->messageBox(-title=>'Information Needed',
				-message=>'Login information is missing or not complete',
				-type=>'OK');
		return 0;
	}
}

#my $result = $tw->update('Hello');

sub timeline {
	$txt->delete('1.0', 'end');

	my $date = DateTime->now();
	
	eval {
		$date->subtract(days=>7);
		my $statuses = $tw->friends_timeline({ since_id => $date, count => 10});
		for my $status (@$statuses) {
			print "\n$status->{time} <$status->{user}{screen_name}> $status->{text}\n";
			$txt->insert('end',"\n$status->{time} <$status->{user}{screen_name}> $status->{text}\n");
		}
	};

	if(my $err = $@) {
		die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

		warn "HTTP Response Code: ", $err->code, "\n",
			 "HTTP Message......: ", $err->message, "\n",
			"Twitter Error.....: ", $err->error, "\n";
	}

#	$txt->insert('end',"Current Time: $date\n\n");
#	$txt->insert('end',"<Person1> This tweet is awesome!\n\n");
#	$txt->insert('end',"<Person2> This tweet is more awesome! It's also really long to test out Perl-Tk's text word wrap!\n\n");
#	$txt->insert('end',"<Person1> This tweet is most awesome!\n\n");
#	$txt->insert('end',"<Person2> Don't give me your crap buddy! Mine's the best!\n\n");
#	$txt->insert('end',"<Person1> Them's fightin words!\n\n");
#	$txt->insert('end',"<Person2> Bring it!\n\n");
#	$txt->insert('end',"<Person1> Oh, it's already been brough'en!\n\n");
}

sub settings {
	## Launch Settings Window ##
	my $settings_win = $mw->Toplevel(-title=>'Settings');
	$settings_win->Label(-text=>'Settings')->pack();

	my $s_frame = $settings_win->Frame()->pack();

	my $s_user_lbl = $s_frame->Label(-text=>'User:');
	my $s_user_entry = $s_frame->Entry(-width=>20);
	my $s_pwd_lbl = $s_frame->Label(-text=>'Password:');
	my $s_pwd_entry = $s_frame->Entry(-width=>20);

	#$settings_win->Button(-text=>'Close', -command=>[$settings_win => 'destroy'])->pack();
	my $save_btn = $s_frame->Button(-text=>'Save', -command=>sub{ save_settings($s_user_entry->get(), $s_pwd_entry->get());  });
	my $close_btn = $s_frame->Button(-text=>'Close', -command=>[$settings_win=>'destroy']);
	
	$s_user_lbl->grid(-row=>1, -column=>1);
	$s_user_entry->grid(-row=>1, -column=>2);
	$s_pwd_lbl->grid(-row=>2, -column=>1);
	$s_pwd_entry->grid(-row=>2, -column=>2);

	$save_btn->grid(-row=>3, -column=>1);
	$close_btn->grid(-row=>3, -column=>2);
	
	## Fill in preference info ##
	$s_user_entry->delete('1.0','end');
	$s_pwd_entry->delete('1.0','end');

	$s_user_entry->insert('end',$pref->username);
	$s_pwd_entry->insert('end',$pref->password);
}

sub save_settings {
	my ($u, $p) = @_;
	$pref->username($u);
	$pref->password($p);

	$pref->write_prefs();
}	

sub refresh {
	if(login()) {
		timeline();
	}
}

refresh();

MainLoop;
