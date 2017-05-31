use 5.10.1;
use strict;
use warnings;
use JSON;
use Data::Dumper;
use Net::STOMP::Client;
use Authen::Credential;
 
my $auth_ssl = Authen::Credential->new(
    scheme => 'x509',
    cert => 'app.crt',
    key =>  'app.key',
);
 
my $stomp = Net::STOMP::Client->new(
    host => '<host>',
    port => 61612,
    auth => $auth_ssl
)->connect;
 
$stomp->message_callback(\&message_callback);
$stomp->subscribe(
    destination => '/queue/<queue_name>',
    id => 'test-client',
    ack => 'client',
);
 
$stomp->wait_for_frames(callback => \&wait_for_exit);
$stomp->unsubscribe(id => 'test-client');
$stomp->disconnect;
 
exit(0);
 
sub message_callback {
    my ($self, $frame) = @_;
    my $headers = $frame->headers;
    print Dumper($headers);
    my $message = $frame->body;
    print Dumper($message);
    print "\n";
    $self->ack(frame => $frame);
    return $self;
}
sub wait_for_exit {
   my($self,$frame) = @_;
   if($frame->command eq 'MESSAGE') {
       return 1 if $frame->body eq 'QUIT';
   }
   return 0;
}
