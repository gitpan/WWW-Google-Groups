# $Id: Search.pm,v 1.4 2003/09/16 15:11:02 cvspub Exp $
package WWW::Google::Groups::Search;

use strict;

use WWW::Mechanize;
use Data::Dumper;


use WWW::Google::Groups::SearchResult;
sub search {
    my $self = shift;
    my %arg = @_;

    $arg{limit} ||= 10;

    $self->{_agent}->get($self->{_server});

    warn "You need to give your query.\n" and return unless $arg{query};
    $self->{_agent}->submit_form(
				 form_number => 1,
				 fields      => {
				     q => $arg{query},
				 }
				 );

    my @result;
    my (@title, @url);
    @url =
        map{$_->[0]}
        grep {$_->[0]=~/threadm=/o}
        $self->{_agent}->links;
    @title = map{$_->[1]} grep {$_->[0]=~/selm=/o} $self->{_agent}->links;
    @result =
	map {+{ _url => $_->[0], _title => $_->[1] }}
    map {[ $url[$_], $title[$_] ]} 0..$#url;

    while(@result < $arg{limit}){
	$self->{_agent}->follow_link( text_regex => qr/\bNext\b/ );
	@url = map{$_->[0]} grep {$_->[0]=~/threadm=/o} $self->{_agent}->links;
	@title = map{$_->[1]} grep {$_->[0]=~/selm=/o} $self->{_agent}->links;
	push @result, 
	map {+{ _url => $_->[0], _title => $_->[1] }}
	map { [ $url[$_], $title[$_] ] } 0..$#url;
    }
    new WWW::Google::Groups::SearchResult($self, \@result);
}



1;
__END__
