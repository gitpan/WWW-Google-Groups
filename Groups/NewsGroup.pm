# $Id: NewsGroup.pm,v 1.4 2003/09/04 07:32:23 cvspub Exp $
package WWW::Google::Groups::NewsGroup;
use strict;
our $VERSION = '0.01';

use WWW::Google::Groups::Thread;

use Storable qw(dclone);
sub new {
    my ($pkg, $arg, $group) = @_;
    my $hash = dclone $arg;
    $hash->{_group} = $group;
    $hash->{_thread_no} = 0;
    bless $hash, $pkg;
}


use WWW::Mechanize;
sub next_thread {
    my $self = shift;

    if(!ref ($self->{_threads}) or !scalar @{$self->{_threads}}){
	my @threads;
	if($self->{_thread_no} % 25){
	    $self->{_agent}->get(
				 $self->{_server}."/groups?hl=en&lr=&ie=UTF-8&safe=off&group=".$self->{_group});
	}
	else{
	    $self->{_agent}->get($self->{_server}."/groups?dq=&num=25&hl=en&lr=&ie=UTF-8&group=".$self->{_group}."&safe=off&start=".$self->{_thread_no});
	}
	my $content = $self->{_agent}->content;

	while( $content =~
	       m!<font face=arial,sans\-serif>(.+?)</font></td><td><font face=arial,sans-serif>.+?</font></td>!mgo ){
	    my $subc = $1;
	    next unless $subc =~ m,a href=/groups,o;
	    $subc =~ m'<a href=(/groups\?.+?) >(.+?)</a>&nbsp; <font size=-1>\((\d+) articles?\)</font>';
	    push @threads, { _url => $1, _title => $2 };
	}
	return unless @threads;
	$self->{_threads} = \@threads;
    }
    $self->{_thread_no}++ if @{$self->{_threads}};
    new WWW::Google::Groups::Thread($self, shift @{$self->{_threads}});
}




1;
__END__
