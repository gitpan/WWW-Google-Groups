# $Id: test.pl,v 1.4 2003/09/04 07:32:23 cvspub Exp $
use Test;
BEGIN { plan tests => 4 };
ok(1);

use WWW::Google::Groups;
use Data::Dumper;

open F, ".proxy";
chomp ($proxy=<F>);
close F;
unlink ".proxy";

$agent = new WWW::Google::Groups(
				 server => 'http://groups.google.com',
				 proxy => $proxy,
				 );

$group = $agent->select_group('comp.lang.perl.misc');

if( $thread = $group->next_thread() ){
    $article = $thread->next_article();
    ok($thread->title);
    ok($article->header('From'));
    ok($article->body);
}
__END__



