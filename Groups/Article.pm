# $Id: Article.pm,v 1.6 2003/09/14 20:02:51 cvspub Exp $
package WWW::Google::Groups::Article;
use strict;
our $VERSION = '0.01';

use Email::Simple;

sub new {
    my ($pkg, $message) = @_;
    return $$message ? Email::Simple->new($$message) : undef;
}

1;
__END__
