# $Id: Groups.pm,v 1.8 2003/09/14 08:29:22 cvspub Exp $
package WWW::Google::Groups;

use strict;
our $VERSION = '0.02';

use WWW::Google::Groups::NewsGroup;
use WWW::Google::Groups::Vars;

use WWW::Mechanize;

sub new {
    my $pkg = shift;
    my %arg = @_;
    foreach my $key (qw(server proxy)){
	next unless $arg{$key};
	$arg{$key} = 'http://'.$arg{$key} if $arg{$key} !~ m,^\w+?://,o;
    }

    my $a = new WWW::Mechanize;
    $a->proxy(['http'], $arg{proxy}) if $arg{proxy};
    $a->agent_alias( $agent_alias[int rand(scalar @agent_alias)] );

    bless {
	_server => $arg{server},
	_proxy => $arg{proxy},
	_agent => $a,
    }, $pkg;
}

sub select_group($$) { new WWW::Google::Groups::NewsGroup(@_) }

use Date::Parse;

sub save2mbox {
    my $self = shift;
    my %arg = @_;
    my $article_count = 0;
    my $thread_count = 0;
    my $max_article_count = $arg{max_article_count};
    my $max_thread_count = $arg{max_thread_count};

    my $group = $self->select_group($arg{group});
    $group->starting_thread($arg{starting_thread});

    open F, '>', $arg{target_mbox} or die "Cannot create mbox $arg{target_mbox}";
    use Data::Dumper;
  MIRROR:
    while( my $thread = $group->next_thread() ){
	while( my $article = $thread->next_article() ){
	    $article->header("From")=~ /\s*([<\(])(.+?@.+?)([>\)])\s*/;
	    my $email = $2;
	    my $date = scalar localtime str2time($article->header("Date"));
	    my $content = $article->as_string;
	    $content =~ s/From:\s.+?\n/From $email $date\n$&/o;
	    print F $content;
	    $article_count++;
	    last MIRROR if
		defined($max_article_count) and
		$article_count >= $max_article_count;
        }
	$thread_count++;
	last MIRROR if
	    defined($max_thread_count) and
	    $thread_count >= $max_thread_count;
    }
    close F;
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

    $group->starting_thread(0);     # Set the first thread to fetch
                                    # Default starting thread is 0

    while( $thread = $group->next_thread() ){
	while( $article = $thread->next_article() ){

            # the returned $article is an Email::Simple object
            # See Email::Simple for its methods

	    print join q/ /, $thread->title, '<'.$article->header('From').'>', $/;
        }
    }

If you push 'raw' to the argument stack of $thread->next_article(), it will return the raw format of messages.

    while( $thread = $group->next_thread() ){
	while( $article = $thread->next_article('raw') ){
	    print $article;
        }
    }



Even, you can use this more powerful method. It will try to mirror the whole newsgroup and save the messages to an Unix mbox.

    $agent->save2mbox(
		      group => 'comp.lang.perl.misc',
		      starting_thread => 0,
		      max_article_count => 10000,
		      max_thread_count => 1000,
		      target_mbox => 'perl.misc.mbox',
		      );


=head1 DESCRIPTION

It is heard that the module (is/may be) violating Google's term of service. So use it at your risk. It is written for crawling back the whole histories of several newsgroups, for my personal interests. Since many NNTP servers do not have huge and complete collections, Google becomes my final solution. However, the www interface of google groups cannot satisfy me well, kind of a keyboard/console interface addict and I would like some sort of perl api. That's why I design this module. And hope Google will not notify me of any concern on this evil.


=head1 COPYRIGHT

xern E<lt>xern@cpan.orgE<gt>

This module is free software; you can redistribute it or modify it under the same terms as Perl itself.

=cut
