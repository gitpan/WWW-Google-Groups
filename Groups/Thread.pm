# $Id: Thread.pm,v 1.6 2003/09/14 08:09:43 cvspub Exp $
package WWW::Google::Groups::Thread;
use strict;
our $VERSION = '0.01';


use WWW::Google::Groups::Article;
use WWW::Google::Groups::Vars;

use Storable qw(dclone);

sub new {
    my ($pkg, $arg, $thread) = @_;
    my $hash = dclone $arg;
    delete $hash->{_threads};
    $hash->{_cur_thread} = $thread;
    $hash->{_cur_thread}->{_url} = $hash->{_server}.$thread->{_url};
    bless $hash, $pkg;
}

sub title() { $_[0]->{_cur_thread}->{_title} }

use WWW::Mechanize;
sub next_article {
    my $self = shift;
    my $type = shift;

    if( !ref ($self->{_mids}) or !scalar @{$self->{_mids}}){
        $self->{_agent}->agent_alias( $agent_alias[int rand(scalar @agent_alias)] );
        $self->{_agent}->get($self->{_cur_thread}->{_url});
	$self->{_agent}->follow_link(n => 2);
        my $content = $self->{_agent}->content;

	my @mids;
	while( $content =~ m,href=/groups\?dq=&hl=en&lr=&ie=UTF-8&safe=off&selm=(.+?) target,go){
	    push @mids, $1;
	}
	$self->{_mids} = \@mids;
    }
    my $this_mid = shift @{$self->{_mids}};
    $self->{_agent}->get($self->{_server}."/groups?selm=${this_mid}&output=gplain");
    if($type =~ /raw/io){
	$self->{_agent}->content();
    }
    else {
	new WWW::Google::Groups::Article(\$self->{_agent}->content());
    }
}






1;
__END__
