# $Id: Groups.pm,v 1.4 2003/09/04 07:32:23 cvspub Exp $
package WWW::Google::Groups;
use strict;
our $VERSION = '0.01';

use WWW::Google::Groups::NewsGroup;

use WWW::Mechanize;
our $my_agent = 'Windows Mozilla';
sub new {
    my $pkg = shift;
    my %arg = @_;
    foreach my $key (qw(server proxy)){
	next unless $arg{$key};
	$arg{$key} = 'http://'.$arg{$key} if $arg{$key} !~ m,^\w+?://,o;
    }

    my $a = new WWW::Mechanize;
    $a->proxy(['http'], $arg{proxy}) if $arg{proxy};
    $a->agent_alias( $my_agent );

    bless {
	_server => $arg{server},
	_proxy => $arg{proxy},
	_agent => $a,
    }, 
}

sub select_group($$) {
    new WWW::Google::Groups::NewsGroup(@_);
}


1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

WWW::Google::Groups - Google Groups Agent

=head1 SYNOPSIS

    use WWW::Google::Groups;

    $agent = new WWW::Google::Groups
                   (
                    server => 'groups.google.com',
                    proxy => 'my.proxy.server:port',
                   );

    $group = $agent->select_group('comp.lang.perl.misc');

    while( $thread = $group->next_thread() ){
	while( $article = $thread->next_article() ){

            # the returned $article is an Email::Simple object
            # See Email::Simple for its methods

	    print join q/ /, $thread->title, '<'.$article->header('From').'>', $/;
        }
    }

=head1 DESCRIPTION

It is heard that the module (is/may be) violating Google's term of service. So use it at your risk. It is written for crawling back the whole histories of several newsgroups, for my personal interests. Since many NNTP servers do not have huge and complete collections, Google becomes my final solution. However, the www interface of google groups cannot satisfy me well, kind of a keyboard/console interface addict and I would like some sort of perl api. That's why I design this module. And hope Google will not notify me of any concern on this evil.


=head1 COPYRIGHT

xern E<lt>xern@cpan.orgE<gt>

This module is free software; you can redistribute it or modify it under the same terms as Perl itself.

=cut
