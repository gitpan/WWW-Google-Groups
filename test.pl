# $Id: test.pl,v 1.11 2003/09/14 20:19:13 cvspub Exp $
use Test::More qw(no_plan);
ok(1);

use Data::Dumper;

BEGIN {
    print "The test needs internet connection. Be sure to get connected, or you will get several error messages.\n";

    use_ok 'WWW::Google::Groups';
    $group = 'comp.lang.perl.misc';
    $target = $group;
    open F, ".proxy";
    chomp ($proxy=<F>);
    close F;
    unlink ".proxy";
}

END{
    unlink $target;
}



$agent = new WWW::Google::Groups(
				 server => 'http://groups.google.com',
				 proxy => $proxy,
				 );

ok($agent->save2mbox(
		     group => $group,
		     starting_thread => 0,
#		     max_article_count => 2,
		     max_thread_count => 2,
		     target_mbox => $target,
	       ));
ok(-f $target);

#__END__

$agent = new WWW::Google::Groups(
				 server => 'http://groups.google.com',
				 proxy => $proxy,
				 );
ok(ref($agent));

$group = $agent->select_group($group);
ok(ref($group));

if( $thread = $group->next_thread() ){
    ok(ref($thread));

    $article = $thread->next_article();
    ok(ref($article));

    ok($thread->title);
    ok($article->header('From'));
    ok($article->body);
}




__END__



