# $Id: Thread.pm,v 1.8 2003/09/14 20:18:47 cvspub Exp $
package WWW::Google::Groups::Thread;
use strict;
our $VERSION = '0.01';


use WWW::Google::Groups::Article;
use WWW::Google::Groups::Vars;

use Storable qw(dclone);

sub new {
    my ($pkg, $arg, $thread) = @_;
    my $hash = dclone $arg;
    return unless defined $thread;
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

    if($self->{_goto_next_thread}){
	$self->{_goto_next_thread} = 0;
	return;
    }

    if( !ref ($self->{_mids}) or !scalar @{$self->{_mids}}){
        $self->{_agent}->agent_alias( $agent_alias[int rand(scalar @agent_alias)] );
        $self->{_agent}->get($self->{_cur_thread}->{_url});
	$self->{_agent}->follow_link(n => 2);

        my $content = $self->{_agent}->content;

	my @mids;
	foreach my $link (grep{/selm=/o}map{$_->url}$self->{_agent}->links){
	    $link =~ /selm=(.+?)$/o;
	    push @mids, $1;
	}
	$self->{_mids} = \@mids;
    }

    $self->{_goto_next_thread} = 1 if 1==scalar@{$self->{_mids}};
    my $this_mid = shift @{$self->{_mids}};
    $self->{_agent}->get($self->{_server}."/groups?selm=${this_mid}&output=gplain");

    $type=~/raw/io?
	$self->{_agent}->content() :
	    new WWW::Google::Groups::Article(\$self->{_agent}->content());
}






1;
__END__
