# by Revok

package pinRecover; 
 
use strict;
use Globals;
use Plugins;
use Misc;
use Network;
use Log qw/message warning error debug/;
use Translation;

Plugins::register('pinRecover', 'recover lost pinCode by bruteforce', \&ul, \&rl);

*Network::Receive::login_pin_code_request = *login_pin_code_request;
sub login_pin_code_request {
	my ($self, $args) = @_;
	message ("Received flag ".$args->{flag}.".\n");
	if ($args->{flag} == 0) { # removed check for seed 0, eA/rA/brA sends a normal seed.
		message (T("PIN code is correct.\n"), "success");
		relog(9999999999999);
	} elsif ($args->{flag} == 1) {
		Log::warning T("Server requested PIN password in order to select your character.\n"), "connection";
		$messageSender->sendLoginPinCode($args->{seed}, 0);
	} elsif ($args->{flag} == 5 || $args->{flag} == 6 || $args->{flag} == 8) {
		error (T("PIN code is incorrect.\n"));
		configModify('loginPinCode', sprintf('%04s', $config{loginPinCode} + 1));
		$messageSender->sendLoginPinCode($args->{seed}, 0);
	}
	$timeout{master}{time} = time;
}

sub rl {
	ul();
}
sub ul {
}
1;