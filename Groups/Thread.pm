# $Id: Thread.pm,v 1.11 2003/09/16 15:11:02 cvspub Exp $
package WWW::Google::Groups::Thread;
use strict;


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

    my $content;
    if( !ref ($self->{_mids}) or !scalar @{$self->{_mids}}){
        $self->{_agent}->agent_alias( $agent_alias[int rand(scalar @agent_alias)] );
        $self->{_agent}->get($self->{_cur_thread}->{_url});

	# get the left frame first
        ($content = $self->{_agent}->content) =~ /left src="(.+?)#s"/s;
	$self->{_agent}->get($self->{_server}.$1);

	my @links;
	foreach my $link (
			  map{s/\x23link\d+$//o;$_}
			  grep {/\x23link\d+$/}
			  map{$_->url}
			  $self->{_agent}->links
			  ){
	    push @links, $link unless $links[$#links-1] eq $link;
	}

	my @mids;
        foreach my $link (@links){
	    $self->{_agent}->get($self->{_server}.$link);
	    foreach my $mlink (grep{!/rnum=/o}
			       grep{/selm=/o}map{$_->url}$self->{_agent}->links){
		$mlink =~ /selm=(.+?)$/o;
		push @mids, $1;
	    }
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
