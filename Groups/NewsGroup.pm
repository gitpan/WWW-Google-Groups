# $Id: NewsGroup.pm,v 1.7 2003/09/14 20:02:51 cvspub Exp $
package WWW::Google::Groups::NewsGroup;
use strict;
our $VERSION = '0.01';

use WWW::Google::Groups::Thread;
use WWW::Google::Groups::Vars;

use Storable qw(dclone);
sub new {
    my ($pkg, $arg, $group) = @_;
    my $hash = dclone $arg;
    $hash->{_group} = $group;
    $hash->{_thread_no} = 0;
    bless $hash, $pkg;
}

sub starting_thread($;$) {
    $_[0]->{_thread_no} = $_[1] if $_[1];
    $_[0]->{_thread_no};
}

use WWW::Mechanize;
sub next_thread {
    my $self = shift;

    if(!ref ($self->{_threads}) or !scalar @{$self->{_threads}}){
	my @threads;
	$self->{_agent}->agent_alias( $agent_alias[int rand(scalar @agent_alias)] );
	$self->{_agent}->get($self->{_server}."/groups?dq=&num=25&hl=en&lr=&ie=UTF-8&group=".$self->{_group}."&safe=off&start=".$self->{_thread_no});
	my $content = $self->{_agent}->content;

	foreach my $link (
			  grep {$_->[0]=~/threadm=/o}
			  grep {$_->[0]=~/groups\?/o}
			  map {[$_->url, $_->text]} $self->{_agent}->links
			  ){
	    push @threads, { _url => $link->[0], _title => $link->[1] };
	}
	return unless @threads;
	$self->{_threads} = \@threads;
    }
    $self->{_thread_no}++ if @{$self->{_threads}};
    new WWW::Google::Groups::Thread($self, shift @{$self->{_threads}});
}




1;
__END__
