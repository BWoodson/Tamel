#!/usr/bin/perl -w

use strict;
use Curses::UI;

# create curses interface
my $cui = new Curses::UI( -color_support => 1);

# create file menu
my @menu = (
	{ -label => 'File',
		-submenu => [
		{ -label => 'Exit		^Q', -value => \&exit_dialog }
	]},
);

# add menu to interface
my $menu = $cui->add(
	'menu', 'Menubar',
	-menu => \@menu,
	-fg => "blue",
);

# add a window
my $win1 = $cui->add(
	'win1', 'Window',
	-border => 1,
	-y => 1,
	-bfg => 'red',
);

# add text editor
my $texteditor = $win1->add(
	'text', 'TextEditor',
	-text => "Here is some text\n"
			. "And some more",
	-padbottom => 10,
	-border => 1
);

# buttons test
my $button_bar = $win1->add(
	'button_bar', 'Buttonbox',
	-buttons => [
		{
		-label => '< Button 1 >',
		-value => 1,
		-shortcut => 1
		},{
		-label => '< Button 2 >',
		-value => 2,
		-shortcut => 2
		}
	],
	-fg => "green",
	-bg => "white"
);

# create some keybindings
$cui->set_binding(sub {$menu->focus()}, "\cX");
$cui->set_binding( \&exit_dialog, "\cQ");

# run our app
$texteditor->focus();
$button_bar->focus();
$cui->mainloop();
# function to exit
sub exit_dialog()
{
	my $return = $cui->dialog(
		-message	=> "Do you really want to quit?",
		-title		=> "Are you sure?",
		-buttons	=> ['yes', 'no'],
	);

	exit(0) if $return;
}
