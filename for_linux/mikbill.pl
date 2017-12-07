use strict;
use vars qw(%RAD_REQUEST %RAD_REPLY %RAD_CHECK);
use IO::Socket;
use locale;
use POSIX;
use PHP::Serialization qw(serialize unserialize);

setlocale(LC_ALL, 'C');

	use constant    RLM_MODULE_REJECT=>    0;#  /* immediately reject the request */
	use constant	RLM_MODULE_FAIL=>      1;#  /* module failed, don't reply */
	use constant	RLM_MODULE_OK=>        2;#  /* the module is OK, continue */
	use constant	RLM_MODULE_HANDLED=>   3;#  /* the module handled the request, so stop. */
	use constant	RLM_MODULE_INVALID=>   4;#  /* the module considers the request invalid. */
	use constant	RLM_MODULE_USERLOCK=>  5;#  /* reject the request (user is locked out) */
	use constant	RLM_MODULE_NOTFOUND=>  6;#  /* user not found */
	use constant	RLM_MODULE_NOOP=>      7;#  /* module succeeded without doing anything */
	use constant	RLM_MODULE_UPDATED=>   8;#  /* OK (pairs modified) */
	use constant	RLM_MODULE_NUMCODES=>  9;#  /* How many return codes there are */

my $sock;
my $answer;
my $time=5;

sub socket_init {
    my $sock = new IO::Socket::INET (
	    PeerAddr => 'localhost',
	    PeerPort => '2007',
	    Proto => 'tcp',
	    );
    die "Error: $!\n" unless $sock;
    return $sock;
}

sub CLONE {
$sock=&socket_init;
}

sub authorize {
	print  $sock "auth\n"; 
	$answer=<$sock>;
	
	print $sock serialize(\%RAD_REQUEST); 
	$answer=<$sock>;
	print $sock serialize(\%RAD_REPLY); 
	$answer=<$sock>;
	print $sock serialize(\%RAD_CHECK); 
	$answer=<$sock>;

        if ($answer eq "reject\n") {
	    return RLM_MODULE_REJECT;
        }
    	$answer=<$sock>;
	%RAD_REPLY=%{unserialize($answer)};
	$answer=<$sock>;
        %RAD_CHECK=%{unserialize($answer)};
        return RLM_MODULE_OK;
}

sub authenticate {
    if ($RAD_REPLY{'Packet-Type'} eq "Access-Reject") {
    return RLM_MODULE_REJECT;
    } else {
    return RLM_MODULE_OK;
    }
}

sub preacct {
	return RLM_MODULE_OK;
}

sub accounting {
	print  $sock "acct\n"; 

	$answer=<$sock>;
	print $sock serialize(\%RAD_REQUEST); 

	return RLM_MODULE_OK;
}

sub checksimul {
	return RLM_MODULE_OK;
}

sub pre_proxy {
	return RLM_MODULE_OK;
}

sub post_proxy {
	return RLM_MODULE_OK;
}

sub post_auth {
	print  $sock "post_auth\n";
	$answer=<$sock>;
	print $sock serialize(\%RAD_REQUEST);
	$answer=<$sock>;
	print $sock serialize(\%RAD_REPLY);
	$answer=<$sock>;
	print $sock serialize(\%RAD_CHECK);
	$answer=<$sock>;
        if ($answer eq "reject\n") {
	    return RLM_MODULE_REJECT;
        }

    	$answer=<$sock>;
	%RAD_REPLY=%{unserialize($answer)};
	$answer=<$sock>;
        %RAD_CHECK=unserialize($answer);

	return RLM_MODULE_OK;
}

sub xlat {
	my ($filename,$a,$b,$c,$d) = @_;
	&radiusd::radlog(1, "From xlat $filename ");
	&radiusd::radlog(1,"From xlat $a $b $c $d ");
	local *FH;
	open FH, $filename or die "open '$filename' $!";
	local($/) = undef;
	my $sub = <FH>;
	close FH;
	my $eval = qq{ sub handler{ $sub;} };
	eval $eval;
	eval {main->handler;};
}

sub detach {
	&radiusd::radlog(0,"rlm_perl::Detaching. Reloading. Done.");
}

sub test_call {
}

sub log_request_attributes {
	for (keys %RAD_REQUEST) {
		&radiusd::radlog(1, "RAD_REQUEST: $_ = $RAD_REQUEST{$_}");
	}
}


